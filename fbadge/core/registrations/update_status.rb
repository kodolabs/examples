module Registrations
  class UpdateStatus < Rectify::Command
    def initialize(event)
      @event = event
    end

    def call
      @event.registrations.update_all(active: @event.active?) if @event.registrations.present?
    end
  end
end
