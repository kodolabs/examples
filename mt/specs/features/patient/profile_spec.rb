require 'rails_helper'

feature 'Patient profile' do
  let(:user)       { create :user }
  let!(:patient)   { create(:patient, user: user).decorate }

  before { user_sign_in user }

  it 'should be navigate-able from homepage' do
    visit '/'
    within('.header__bottom-part') do
      click_on 'My Account'
    end
    expect(page).to have_content 'Billing Details'
  end

  context 'view' do
    it 'should show profile form' do
      visit patient_profile_path
      expect(page).to have_content 'Billing Details'

      expect(page).to have_field 'First name', with: patient.first_name
      expect(page).to have_field 'Last name', with: patient.last_name
      expect(page).to have_field 'Address', with: patient.address
      expect(page).to have_field 'City', with: patient.city
      expect(page).to have_select 'Country'
      expect(page).to have_field 'Email', with: user.email
      expect(page).to have_field 'Religion', with: patient.religion
      expect(page).to have_field 'Diet', with: patient.diet
    end
  end

  context 'update profile' do
    it 'should save details' do
      visit patient_profile_path

      within 'form.form-profile' do
        fill_in 'First name', with: 'John'
        fill_in 'Last name', with: 'Smith'
        fill_in 'Address', with: 'Baker st.'
        fill_in 'City', with: 'London'
        select 'United Kingdom', from: 'Country'
        fill_in 'Phone', with: '191919'
        fill_in 'Religion', with: 'Christian'
        fill_in 'Diet', with: 'First'

        first(:button, 'Submit').click
      end

      expect(page).to have_content 'Successfully updated'
      expect(page).to have_field 'First name', with: 'John'
      expect(page).to have_field 'Last name', with: 'Smith'
      expect(page).to have_field 'Address', with: 'Baker st.'
      expect(page).to have_field 'City', with: 'London'
      expect(page).to have_select 'Country', selected: 'United Kingdom'
      expect(page).to have_field 'Phone', with: '191919'
      expect(page).to have_field 'Religion', with: 'Christian'
      expect(page).to have_field 'Diet', with: 'First'
    end
  end

  context 'update password' do
    it 'should change password' do
      visit patient_profile_path

      within 'form.form-password' do
        fill_in 'New password', with: '123123123'
        fill_in 'Re-enter password', with: '123123123'
        click_button 'Submit'
      end

      expect(page).to have_content 'Your password was successfully updated'
    end
  end
end
