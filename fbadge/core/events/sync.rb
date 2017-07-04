module Events
  class Sync < Rectify::Command
    def initialize(user, event_id)
      @user = user
      @event = Event.find(event_id)
    end

    def call
      EventbriteWorker.perform_async(@user.id, @event.id)
      broadcast(:ok, @event)
    end
  end
end
