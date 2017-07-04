module Notifications
  class Create < Rectify::Command
    def initialize(form, event, user)
      @form = form
      @event = event
      @sender = user.event_organiser_profile(@event)
    end

    def call
      return broadcast(:invalid) if @form.invalid?
      return broadcast(:inactive_event, @event) unless @event.active?
      notification = @event.notifications.create(title: @form.title, text: @form.text, sender: @sender)
      if notification
        NotificationStatusWorker.perform_async(notification.id)
        broadcast(:ok, @event)
      else
        broadcast(:invalid)
      end
    end
  end
end
