require 'rails_helper'

describe 'Inquiry registration' do
  context 'success' do
    specify 'create' do
      email = FFaker::Internet.email
      username = FFaker::Name.name
      phone = FFaker::PhoneNumberAU.international_mobile_phone_number
      visit registration_path
      fill_in 'Email address', with: email
      fill_in 'Name', with: username
      fill_in 'Phone number', with: phone
      check 'I am a registered health practitioner'
      check 'I have read and accept the Influenza Privacy Policy & Terms and Conditions'
      expect_any_instance_of(Inquiry).to receive(:send_emails).once
      click_on 'Start'
      expect(page).to have_flash 'Thank you. Please check your email!'
      inquiry = Inquiry.last
      expect(inquiry.email).to eq(email)
      expect(inquiry.username).to eq(username)
      expect(inquiry.phone).to eq(phone)
    end
  end

  context 'fail' do
    specify 'blank fields' do
      visit registration_path
      click_on 'Start'
      expect(page).to have_content "can't be blank"
      expect(Inquiry.count).to eq(0)
    end
  end
end
