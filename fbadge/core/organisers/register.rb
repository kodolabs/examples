module Organisers
  class Register < Rectify::Command
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) if @form.invalid?

      user_attributes = @form.attributes
      token = user_attributes.delete :token

      invitation = OrganiserInvitation.pending.find_by token: token

      if invitation
        user = User.create! user_attributes
        user.create_organiser

        invitation.update accepted_at: Time.zone.now

        broadcast :ok, user
      else
        @form.errors.add :base, 'Registration by invitation only'
        broadcast :error
      end
    end
  end
end
