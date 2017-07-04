require 'rails_helper'

describe InvalidAccountMailer, type: :mailer do
  describe 'notification' do
    let(:customer) { create(:customer, :with_active_subscr, :with_profile) }
    let(:account) { create(:account, :with_invalid_token, :facebook, customer: customer) }
    let(:mail) { InvalidAccountMailer.notification(customer.id) }

    specify 'success' do
      account
      body = mail.body.encoded
      link = "<a href=3D\"#{user_accounts_url}\">here.</a>"
      expect(body).to include "Dear #{customer.primary_user.profile.full_name}"
      expect(mail.from.first).to eq Setting['email.sender']
      expect(mail.to.first).to eq customer.primary_user.email
      expect(body).to include 'Reconnect your Facebook account'
      expect(body).to include link
      expect(customer.reload.notified_at).to be_truthy
    end
  end
end
