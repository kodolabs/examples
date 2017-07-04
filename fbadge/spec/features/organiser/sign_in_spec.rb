require 'rails_helper'

feature 'Organiser sign in' do
  let!(:user) { create :user, :organiser }

  context 'with valid credentials' do
    it 'should be successful' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
      expect(page).to have_content 'Logout'
    end
  end

  context 'with invalid credentials' do
    it 'should fail' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'fakepassword'
      click_button 'Log in'
      within '.alert-warning' do
        expect(page).to have_content 'Invalid Email or password.'
      end
    end
  end
end
