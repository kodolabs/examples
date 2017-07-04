module Integrations
  module Eventbrite
    class CreateEvent < Rectify::Command
      require 'eventbrite'

      TIMEZONE = 'Europe/Moscow'.freeze

      def initialize(user, event)
        @user = user
        @event = event
        ::Eventbrite.token = @user.organiser.eventbrite_token
      end

      def call
        create_event(@event)
      end

      private

      def create_event(event)
        params = {
          'event.name.html': event.name,
          'event.description.html': event.description,
          'event.start.utc': event_date_utc(event.begins_on, event.locations.first.slots.first.begins_at),
          'event.end.utc': event_date_utc(event.ends_on, event.locations.first.slots.first.ends_at),
          'event.currency': 'USD',
          'event.start.timezone': TIMEZONE,
          'event.end.timezone': TIMEZONE,
          'event.logo_id': event.eventbrite_logo_id
        }
        eventbrite_event = ::Eventbrite::Event.create(params)
        event.update_attributes(
          eventbrite_response: eventbrite_event,
          eventbrite_id: eventbrite_event[:id],
          sync_error: nil
        )
      rescue StandardError => e
        save_error(event, e)
        Rollbar.error(e)
      end

      def event_date_utc(date, time)
        event_date = date.strftime('%Y-%m-%d')
        event_time = time.strftime('%H:%M:%S')
        event_date + 'T' + event_time + 'Z'
      end

      def save_error(event, error)
        error = { message: error.message }
        event.update_attributes(sync_error: error)
      end
    end
  end
end
