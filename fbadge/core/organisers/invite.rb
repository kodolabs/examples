module Organisers
  class Invite < Rectify::Command
    def initialize(admin, form)
      @admin = admin
      @form = form
    end

    def call
      return broadcast(:invalid) if @form.invalid?

      invitee = @form.email
      user = find invitee

      if user.present?
        if user.organiser.blank?
          promote_user user
          broadcast :granted
        else
          broadcast :exists
        end
      else
        send_invitation invitee
        broadcast :ok
      end
    end

    private

    def promote_user(user)
      user.create_organiser
      UserMailer.promoted_to_organiser(user).deliver_now
    end

    def send_invitation(invitee)
      invitation = OrganiserInvitation.create! invitee_email: invitee,
                                               inviter: @admin

      InvitationMailer.invitation(invitation).deliver_now
    end

    def find(email)
      User.find_by email: email
    end
  end
end
