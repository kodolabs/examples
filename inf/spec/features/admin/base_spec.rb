require 'rails_helper'

feature 'Admin' do
  let(:admin) { create :admin }

  context 'should log in' do
    it 'and see successfully message' do
      visit new_admin_session_path
      fill_in 'Email', with: admin.email
      fill_in 'Password', with: admin.password
      click_button 'Log in'
      expect(page).to have_flash 'Signed in successfully.'
    end
  end
end
