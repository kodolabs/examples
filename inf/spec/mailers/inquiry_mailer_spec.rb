require 'rails_helper'

RSpec.describe InquiryMailer, type: :mailer do
  describe 'requester' do
    let(:inquiry) { create(:inquiry) }
    let(:mail) { InquiryMailer.requester(inquiry) }
    let(:customer) { create(:customer, :demo) }

    specify 'success' do
      inquiry
      body = mail.body.encoded
      expect(body).to include 'Thank you for registering'
      expect(body).to include 'A member of our team will be in touch'
      expect(mail.to.first).to eq inquiry.email
      expect(mail.from.first).to eq Setting['email.sender']
    end

    specify 'demo success' do
      customer
      inquiry
      body = mail.body.encoded
      expect(body).to include customer.decorate.demo_sign_in_link
    end
  end

  describe 'notification' do
    let(:inquiry) { create(:inquiry) }
    let(:mail) { InquiryMailer.notification(inquiry) }
    let(:customer) { create(:customer) }

    specify 'success' do
      inquiry
      body = mail.body.encoded

      expect(body).to include inquiry.username
      expect(body).to include inquiry.email
      expect(body).to include inquiry.phone

      expect(mail.from.first).to eq Setting['email.sender']
    end
  end
end
