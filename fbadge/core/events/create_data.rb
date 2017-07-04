module Events
  class CreateData < Rectify::Command
    def initialize(event, user)
      @event = event
      @user = user
    end

    def call
      create_associated_data(@event, @user)
      EventbriteWorker.perform_async(@user.id, @event.id)
    end

    private

    def create_associated_data(event, user)
      create_profile(event, user)
      location = create_location(event)
      create_slot(location, event)
    end

    def create_profile(event, user)
      Profile.create({ user: user, event: event, role: :organiser }.merge(user.profile_attributes))
    end

    def create_location(event)
      event.locations.create(name: 'First Location')
    end

    def create_slot(location, event)
      (event.begins_on..event.ends_on).each do |date|
        begins_at = create_time_point(date, '1:00')
        ends_at = create_time_point(date, '23:00')
        location.slots.create(begins_at: begins_at, ends_at: ends_at)
      end
    end

    def create_time_point(date, time)
      date.to_datetime + Time.parse(time).seconds_since_midnight.seconds
    end
  end
end
