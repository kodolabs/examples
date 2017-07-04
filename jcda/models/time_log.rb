class TimeLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  belongs_to :payment
  has_many :requests

  scope :ordered, -> { order clock_in: :desc }
  scope :last_periods, -> { where("clock_in >= :date", date: 180.days.ago) }
  scope :late, -> { where.not late_by: nil }
  scope :by_location, -> (location_id) { where location_id: location_id }
  scope :between, -> (start_date, end_date) { where("clock_in >= ? AND clock_in <= ?", start_date, end_date ) }
  scope :clock_out_between, -> (start_date, end_date) { where clock_out: start_date...end_date }

  scope :previous_time_logs_on_current_week, -> (current_time_log) do
    beginning_of_range = current_time_log.clock_in.beginning_of_week(:sunday)
    end_of_range       = current_time_log.clock_in
    user = current_time_log.user
    where(clock_in: beginning_of_range...end_of_range, user: user)
  end

  scope :next_time_logs_on_current_week, -> (current_time_log) do
    beginning_of_range = current_time_log.clock_in + 1.second
    end_of_range       = current_time_log.clock_in.end_of_week(:sunday)
    user = current_time_log.user
    where(clock_in: beginning_of_range...end_of_range, user: user)
  end

  validates :user, presence: true
  validates :clock_in, :location, presence: true, if: 'user.hourly?'
  validates :clock_out, presence: true, unless: :timelog_last?
  validate :user_hourly?
  validate :clocked_out?, on: :create, if: :user, unless: :clock_out
  validate :clocked_in?, if: 'user.hourly?'
  validate :clock_in_must_be_before_clock_out, if: [:clock_in, :clock_out]
  validate :is_payroll_open?, if: :clock_in

  before_save :count_worked_hours, if: :clock_out
  before_save :check_lateness
  after_save :recalc_future_time_logs, if: :total_changed?
  before_destroy :deny_requests

  delegate :name, to: :location, prefix: true

  def self.clock_in(user, location)
    ClockIn.new(user, location).create
  end

  def self.clock_out(user)
    time_log = find_or_initialize_by(user: user, clock_out: nil)
    time_log.tap { |time_log| time_log.update clock_out: user_time_with_time_zone(time_log.location) }
  end

  def recalc_future_time_logs
    TimeLog.next_time_logs_on_current_week(self).each(&:save)
  end

  def timelog_last?
    user.time_logs.where('clock_in > ? AND id <> ?', clock_in, (id || 0)).empty?
  end

  def is_payroll_open?
    return unless clock_in < Payroll.current.start_date
    errors.add(:clock_in, "payroll submitted")
  end

  def clock_in_must_be_before_clock_out
    errors.add(:clock_in, "must be before clock out time") if clock_in >= clock_out
  end

  def editable?
    if payment.present? && (payment.edited? || payment.payroll.submitted?)
      false
    else
      true
    end
  end

  def submitted?
    payment.present? && payment.payroll.submitted?
  end

  def duration_in_hours
    ((clock_out - clock_in) / 1.hour).round(2) if clock_out
  end

  def late?
    !!late_by
  end

  def opened?
    !clock_out
  end

  def self.with_timezone(tz, &block)
    old_tz = Time.zone
    Time.zone = tz unless tz.blank?
    return block.call
  ensure
    Time.zone = old_tz
  end

  def update_in_timezone(params)
    TimeLog.with_timezone(location.timezone) do
      update(params)
    end
  end

  def self.new_in_timezone(params)
    location = Location.find_or_initialize_by(id: params[:location_id])
    TimeLog.with_timezone(location.timezone) do
      new(params)
    end
  end

  private

  # TODO: should be moved into location
  def self.user_time_with_time_zone(location)
    if location
      Time.now.in_time_zone(location.timezone)
    else
      Time.now
    end
  end

  def clocked_out?
    if user.time_logs.find_by(clock_out: nil)
      errors.add(:clock_in, 'You are not clocked-out.')
    end
  end

  def clocked_in?
    errors.add(:clock_out, 'You are not clocked-in.') unless clock_in
  end

  def count_worked_hours
    self.total = (clock_out - clock_in) / 3600
    self.overtime = count_overtime
    self.regular = total - overtime
  end

  def count_overtime
    prev_time = TimeLog.previous_time_logs_on_current_week(self).inject(0) do |total, time_log|
      total + time_log.total
    end

    if prev_time > 40
      total
    else
      prev_time += total
      prev_time > 40 ? prev_time - 40 : 0
    end
  end

  def deny_requests
    requests.pending.update_all(status: Request.statuses[:denied], decline_reason: 'Clock-in deleted.')
  end

  def check_lateness
    if expected_time.present? && clock_in > expected_time + 7.minutes
      self.late_by = (clock_in - expected_time).round
    else
      self.late_by = nil
    end
  end

  def user_hourly?
    unless user.try(:hourly?)
      errors.add(:base, 'You should be hourly rated employee to clock-in/clock-out.')
    end
  end
end
