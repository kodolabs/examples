require 'rails_helper'

feature 'Manager profile' do
  let!(:manager)   { create :manager }
  let!(:hospital)  { create :hospital, manager: manager }

  before { manager_sign_in manager }

  context 'view' do
    it 'should show profile form' do
      visit manager_profile_path
      expect(page).to have_content 'Contact details'

      expect(page).to have_field 'First name', with: manager.first_name
      expect(page).to have_field 'Last name', with: manager.last_name
      expect(page).to have_field 'Phone', with: manager.phone
      expect(page).to have_field 'Email', with: manager.email
    end
  end

  context 'update profile' do
    it 'should save details' do
      visit manager_profile_path

      within 'form.form-profile' do
        fill_in 'First name', with: 'Jurgen'
        fill_in 'Last name', with: 'Smirnoff'
        fill_in 'Phone', with: '191919'
        click_button 'Submit'
      end

      expect(page).to have_content 'Successfully updated'
      expect(page).to have_field 'First name', with: 'Jurgen'
      expect(page).to have_field 'Last name', with: 'Smirnoff'
      expect(page).to have_field 'Phone', with: '191919'
    end
  end

  context 'update password' do
    it 'should change password' do
      visit manager_profile_path

      within 'form.form-password' do
        fill_in 'New password', with: '123123123'
        fill_in 'Re-enter password', with: '123123123'
        click_button 'Submit'
      end

      expect(page).to have_content 'Your password was successfully updated'
    end
  end
end
