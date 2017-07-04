require 'rails_helper'

feature 'Facilitator profile' do
  let!(:facilitator) { create :facilitator }

  before { facilitator_sign_in facilitator }

  context 'view' do
    it 'should show profile form' do
      visit facilitator_profile_path
      expect(page).to have_content 'Profile details'

      expect(page).to have_field 'First name', with: facilitator.first_name
      expect(page).to have_field 'Last name', with: facilitator.last_name
      expect(page).to have_field 'Email', with: facilitator.email
    end
  end

  context 'update profile' do
    it 'should save details' do
      visit facilitator_profile_path

      within 'form.form-profile' do
        fill_in 'First name', with: 'John'
        fill_in 'Last name', with: 'Snow'
        click_button 'Submit'
      end

      expect(page).to have_content 'Successfully updated'
      expect(page).to have_field 'First name', with: 'John'
      expect(page).to have_field 'Last name', with: 'Snow'
    end
  end

  context 'update password' do
    it 'should change password' do
      visit facilitator_profile_path

      within 'form.form-password' do
        fill_in 'New password', with: '123123123'
        fill_in 'Re-enter password', with: '123123123'
        click_button 'Submit'
      end

      expect(page).to have_content 'Your password was successfully updated'
    end
  end
end
