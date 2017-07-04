class Payroll < ActiveRecord::Base
  PERIODS_START_DAYS = {first: 5, second: 21}

  has_many :payments, dependent: :restrict_with_error

  validates :regular_hours,
            :overtime_hours,
            :sick_hours,
            :vacation_hours,
            :base_pay,
            :bonus_pay,
            :gross_pay, presence: true, numericality: { greater_than_or_equal_to: 0, allow_nil: false }, on: :update

  validates :start_date, :end_date, presence: true
  validate  :check_end_day, if: :submitted

  scope :ordered, -> { order start_date: :desc }
  scope :submitted, -> { where submitted: true }
  scope :opened, -> { where submitted: false }

  before_validation :start_and_end_dates

  def self.current
    opened.order(start_date: :asc).first
  end

  def calculate
    return if submitted?

    payments.destroy_all

    #
    # This summary doesn't actually update anything in the databae.
    # We need to assign each payment to this payroll as well as update
    # the timelogs so they refer to the proper payment.
    #
    Payment.summary(start_date, end_date).each do |p|
      # update the payment object
      p.payroll_id = self.id
      p.save!

      # now all the time logs related to this payment
      TimeLog.where(id: p.tLogs).update_all(payment_id: p) if p.tLogs
    end

    update_self_summaries
  end

  def bulk_update(params)
    params[:payment].each do |id, values|
      payment = Payment.find(id.to_i)
      payment.update!(payment_params(values).merge(edited_at: Time.now))
      update_self_summaries
    end
  end

  private

  def check_end_day
    if DateTime.current < end_date
      errors.add :end_date, "Unable to submit payroll until it ends."
    end
  end

  def payment_params(payment_hash)
    payment_hash.slice(
      :pay_rate, :regular_hours, :overtime_hours, :sick_hours, :vacation_hours,
      :bonus_pay
    ).permit!
  end

  def update_self_summaries
    params = payments.select("SUM(payments.regular_hours) AS regular_hours,
                              SUM(payments.overtime_hours) AS overtime_hours,
                              SUM(payments.sick_hours) AS sick_hours,
                              SUM(payments.vacation_hours) AS vacation_hours,
                              SUM(payments.base_pay) AS base_pay,
                              SUM(payments.bonus_pay) AS bonus_pay,
                              SUM(payments.gross_pay) AS gross_pay")[0].attributes.compact
    update params
  end

  def start_and_end_dates
    return if start_date

    if Payroll.count == 0
      next_start_date = next_end_date(DateTime.current) + 1.seconds
    else
      next_start_date = Payroll.ordered.first.end_date + 1.seconds

      unless DateTime.current.day == next_start_date.day
        errors.add(:base, "can be created only at first payroll day")
        return
      end
    end

    self.start_date = next_start_date
    self.end_date = next_end_date(start_date)
  end

  def next_end_date(start_date)
    today = DateTime.current
    [
      today.beginning_of_month + time_from_beginning_of_month_to_end_date(:first),
      today.beginning_of_month + time_from_beginning_of_month_to_end_date(:second),
      today.next_month.beginning_of_month + time_from_beginning_of_month_to_end_date(:first),
      today.next_month.beginning_of_month + time_from_beginning_of_month_to_end_date(:second),
    ].detect do |date|
      date.to_date > start_date.to_date
    end
  end

  def time_from_beginning_of_month_to_end_date(period_number)
    PERIODS_START_DAYS[period_number].days - 1.days - 1.seconds
  end
end
