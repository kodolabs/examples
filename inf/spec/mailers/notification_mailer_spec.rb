require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  describe 'new_customer' do
    let(:customer) { create(:customer, :with_profile) }

    specify 'success' do
      customers = [customer]

      customers.each do |customer|
        user = customer.primary_user
        mail = NotificationMailer.new_customer(customer)
        body = mail.body.encoded
        fields = [
          user.profile.full_name,
          user.email,
          user.profile.phone
        ]

        fields.each do |field|
          expect(body).to include field
        end

        expect(mail.to.first).to eq Setting['email.recipient']
        expect(mail.from.first).to eq Setting['email.sender']
      end
    end
  end
end
