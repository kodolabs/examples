require 'rails_helper'

describe 'Standard registration' do
  context 'success' do
    specify 'create' do
      email = FFaker::Internet.email
      visit root_path
      find('a.btn-signup:first').click
      fill_in 'Email', with: email
      fill_in 'Password', with: 'awesomepassword'
      check 'I am a registered health practitioner'
      check 'I have read and accept the Influenza Privacy Policy & Terms and Conditions'
      click_on 'Register'
      expect(current_url).to eq welcome_users_url(email: email)
    end
  end

  context 'fail' do
    specify 'blank fields' do
      visit sign_up_path
      click_on 'Register'
      expect(page).to have_content "can't be blank"
      expect(User.count).to eq(0)
    end
  end
end
