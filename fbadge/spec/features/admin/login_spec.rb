require 'rails_helper'

feature 'Admin login' do
  let!(:admin) { create(:admin) }

  describe 'Login as admin' do
    before { visit new_admin_session_path }

    it 'should login with valid credentials' do
      fill_in 'admin_email', with: admin.email
      fill_in 'admin_password', with: admin.password
      click_on 'Log in'
      expect(page).to have_content 'Signed in successfully.'
    end

    it 'should not login and show error with invalid credentials' do
      fill_in 'admin_email', with: 'email@email'
      fill_in 'admin_password', with: 'wrong_password'
      click_on 'Log in'
      expect(page).to have_content 'Invalid Email or password. '
    end
  end
end
