module Receptionists
  class Create < Rectify::Command
    def initialize(form, event)
      @form = form
      @event = event
    end

    def call
      return broadcast(:invalid) if @form.invalid?
      receptionist = create_receptionist(@form, @event)
      return broadcast(:invalid) unless receptionist
      Receptionists::Invite.call(receptionist, @event)
      broadcast(:ok, @event)
    end

    private

    def create_receptionist(form, event)
      Receptionist.create(form.attributes.merge(event: event, token: generate_token))
    end

    def generate_token
      SecureRandom.uuid
    end
  end
end
