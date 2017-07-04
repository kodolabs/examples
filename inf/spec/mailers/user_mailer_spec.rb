require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'confirmation' do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.confirmation_instructions(user, 123) }

    specify 'success' do
      expect(mail.body.encoded).to include 'to confirm your email.'
      expect(mail.body.encoded).to include '/confirmation'
      expect(mail.to.first).to eq user.email
      expect(mail.from.first).to eq Setting['email.sender']
      expect(mail.subject).to eq 'Thank you for registering with Influenza.ai'
    end
  end
end
