module Receptionists
  class Invite < Rectify::Command
    def initialize(receptionist, event)
      @receptionist = receptionist
      @event = event
    end

    def call
      InvitationMailer.receptionist_invitation(@receptionist, @event).deliver_now
    end
  end
end
