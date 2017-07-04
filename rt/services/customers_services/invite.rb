module CustomersServices
  class Invite
    def initialize(customer, user = nil)
      @customer = customer
      @user = user || @customer.primary_user
    end

    def call
      token, = Devise.token_generator.generate(User, :invitation_token)
      user.update(invitation_token: token)
      UserEmails.send(customer.payment_info? ? :invite_with_payment_info : :invite, user).deliver_later
    end

    private

    attr_reader :customer, :user
  end
end
