class OpenHours
  attr_accessor :params, :result

  def initialize(params)
    @params = params
    @result = []
    init_dates_range
  end

  def call
    open_hours.sort_by { |row| row[:date].in_time_zone }
  end

  private

  def init_dates_range
    start_datetime = params[:start_date].to_datetime
    end_datetime = params[:end_date].to_datetime
    @dates_range = (start_datetime.to_i..end_datetime.to_i).step(1.day)
  end

  def open_hours
    location_query.map do |location|
      location_open_hours(location)
    end
    result
  end

  def location_query
    query = Location.joins(:calendar)
    if params[:location_id].present?
      query = query.where(id: params[:location_id])
    end
    query
  end

  def location_open_hours(location)
    @dates_range.each do |time|
      location_open_hours_by_date(location, Time.at(time).to_date)
    end
  end

  def location_open_hours_by_date(location, date)
    times = expected_times_for_user_by_date(location.calendar, date).reject(&:blank?)

    if times.blank?
      time_logs = location_users_time_logs_by_date(location, date)
      start_time, end_time = from_timelog(time_logs)
    else
      start_time = times.map { |item| item[:start] }.compact.min
      end_time = times.map { |item| item[:end] }.compact.max
    end

    return if start_time.blank? || end_time.blank?

    @result << {
      date: date,
      location: location.id,
      location_name: location.name,
      phone: location.phone,
      opened_at: start_time.in_time_zone(location.timezone),
      closed_at: end_time.in_time_zone(location.timezone)
    }
  end

  def expected_times_for_user_by_date(calendar, date)
    day = date.beginning_of_day..date.end_of_day
    times = calendar_items_by_date(calendar, date).map do |item|
      item.attributes.slice('start', 'end').symbolize_keys!
    end

    return times if times.present?

    expected_times = {}
    recurrent_events(calendar, date).detect do |recurrent_event|
      recurrent_event.recurrence.detect do |rule|
        schedule = IceCube::Schedule.from_ical rule
        schedule.start_time = recurrent_event.start

        recurrent_event.attributes.slice('start', 'end').each do |field, time|
          expected_times[field] = recurrent_event[field].change(
            hour: time.hour,
            min: time.min
          ).utc
        end if schedule.occurs_on? date
      end
    end
    [expected_times.symbolize_keys!]
  end

  def location_users_time_logs_by_date(location, date)
    location.time_logs.where("DATE(clock_in) = ?", date)
  end

  def calendar_items_by_date(calendar, date)
    calendar.calendar_items.where("DATE(start) = ?", date)
  end

  def recurrent_events(calendar, date)
    calendar.calendar_items
      .where.not(recurrence: nil)
      .where('DATE(start) <= ?', date)
      .order(start: :desc)
  end

  def from_timelog(time_logs)
    [
      time_logs.pluck(:clock_in).compact.min,
      time_logs.pluck(:clock_out).compact.max
    ]
  end
end
