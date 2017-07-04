class Payment < ActiveRecord::Base
  OVERTIME_FACTOR=1.5
  belongs_to :payroll
  belongs_to :user
  belongs_to :location
  has_many   :time_logs, dependent: :nullify

  enum pay_type: [:hourly, :salary]

  validates :regular_hours,
            :overtime_hours,
            :sick_hours,
            :vacation_hours,
            :base_pay,
            :bonus_pay,
            :gross_pay, presence: true, numericality: { greater_than_or_equal_to: 0, allow_nil: false }, on: :update
  validates :payroll, presence: true

  before_validation :calculate_summaries

  delegate :name, to: :location, prefix: true, allow_nil: true

  # this is used to store non-updated time log data before a payment is saved
  attr_accessor :tLogs

  def self.summarize_by_user
    select("SUM(payments.regular_hours) AS regular_hours,
            SUM(payments.overtime_hours) AS overtime_hours,
            SUM(payments.sick_hours) AS sick_hours,
            SUM(payments.vacation_hours) AS vacation_hours,
            SUM(payments.base_pay) AS base_pay,
            SUM(payments.bonus_pay) AS bonus_pay,
            SUM(payments.gross_pay) AS gross_pay,
            user_id,
            payroll_id,
            pay_type,
            pay_rate
          ").group(:user_id, :payroll_id, :pay_type, :pay_rate).order(:user_id)
  end

  def edited?
    !!edited_at
  end

  def total_hours
    [regular_hours, overtime_hours, sick_hours, vacation_hours].compact.sum
  end

  #
  # Get a summary of times worked and pay over any arbitrary time frame.
  #
  def self.summary(start_time, end_time)
    @payment_data = Array.new

    raw_time_logs = TimeLog.includes(:user).includes(:location).where(clock_in: start_time..end_time).where.not(clock_out: nil)
    grouped_time_logs = raw_time_logs.group_by { |time_log| [time_log.user, time_log.location] }
    grouped_time_logs.each do |key, time_logs|
      user, location = key
      payment = new(user: user, location: location, tLogs: time_logs)

      #
      # It's possible that a user was converted from hourly to
      # salary. If so, we need to make a guess as to what their pay
      # was during the time in question. We'll do this by assuming
      # the first existing payment in the database since the start_time
      # is the proper hourly pay for this employee.
      #
      # TODO: This should be fixed by actually tracking pay within the time log.
      #
      pay = user.pay
      if user.salaried?
        # there SHOULD be a payment object for this user
        pay = Payment.where(['user_id = ? and created_at >= ?', user.id, start_time]).order(:created_at).first.pay_rate
      end

      params = {
          pay_type: :hourly,
          pay_rate: pay,
          regular_hours: 0,
          overtime_hours: 0,
          sick_hours: sick_hours(user, start_time, end_time),
          vacation_hours: vacation_hours(user, start_time, end_time),
      }

      time_logs.inject(params) do |params, time_log|
        params[:regular_hours] += time_log.regular
        params[:overtime_hours] += time_log.overtime
        params
      end

      payment.assign_attributes(params)
      payment.calculate_summaries
      @payment_data << payment
    end

    #
    # TODO: What if the person was not salaried for the time period indicated?
    #
    User.salaried.each do |user|
      payment = Payment.new({
                               user: user,
                               pay_type: :salary,
                               pay_rate: user.pay / 24,
                               regular_hours: 0,
                               overtime_hours: 0,
                               sick_hours: sick_hours(user, start_time, end_time),
                               vacation_hours: vacation_hours(user, start_time, end_time),
                            })
      payment.calculate_summaries
      @payment_data << payment
    end

    @payment_data
  end

  def calculate_summaries
    self.base_pay = calculate_base_pay
    self.bonus_pay ||=0
    self.gross_pay = base_pay + bonus_pay
  end

  private

  def calculate_base_pay
    if hourly?
      (regular_hours + sick_hours + vacation_hours) * pay_rate + overtime_hours * pay_rate * OVERTIME_FACTOR
    else
      pay_rate
    end
  end

  #
  # Calculate sick/vacation time. This is a bit more complicated
  # because a user may work in multiple locations but their
  # sick time should only be applied once.
  #
  def self.sick_hours(user, start_date, end_date)
    return 0 if @payment_data.find { |p| p.user_id == user.id }

    user.sick_time_journals.use.between(start_date, end_date).sum(:amount).abs
  end

  def self.vacation_hours(user, start_date, end_date)
    return 0 if @payment_data.find { |p| p.user_id == user.id }

    user.vacation_time_journals.use.between(start_date, end_date).sum(:amount).abs
  end
end
