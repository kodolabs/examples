class ClockIn < Struct.new(:user, :location)
  def create
    TimeLog.create({
      user: user,
      clock_in: user_time_with_time_zone(location),
      location: location,
      expected_time: expected_time
    })
  end

  private

  def expected_time
    @expected_time ||= CalendarItem.expected_time_for(user)
  end

  def user_time_with_time_zone(location)
    if location
      Time.now.in_time_zone(location.timezone)
    else
      Time.now
    end
  end
end
