require 'rails_helper'

describe CustomersServices::Invite do
  let(:customer) { create :customer }

  let(:second_user) { create :user, customer: customer }

  describe '#call' do
    let(:service) { CustomersServices::Invite.new(customer) }

    it 'generate token for user' do
      expect(customer.primary_user.invitation_token).to be_nil
      service.call
      expect(customer.primary_user.invitation_token).to_not be_nil
    end

    it 'add mail to queue' do
      expect(UserEmails).to receive(:invite).with(customer.primary_user).and_return(double('mailer', deliver_later: true))
      service.call
    end

    it 'customer without payment info' do
      expect(UserEmails).to receive(:invite).with(customer.primary_user).and_return(double('mailer', deliver_later: true))
      service.call
    end

    it 'customer without payment info' do
      expect(customer).to receive(:payment_info?).and_return(true)
      expect(UserEmails).to receive(:invite_with_payment_info).with(customer.primary_user).and_return(double('mailer', deliver_later: true))
      service.call
    end

    it 'send not for primary user' do
      CustomersServices::Invite.new(customer, second_user).call

      expect(ActionMailer::Base.deliveries.last).to_not be_nil
      expect(ActionMailer::Base.deliveries.last.to[0]).to eq second_user.email
    end
  end
end
