require 'rails_helper'

feature 'Organiser Registration by Invitation' do
  let(:invitation) { create :organiser_invitation }

  context 'with valid credentials' do
    it 'should be successful' do
      visit organiser_registration_path token: invitation.token

      fill_in_registration_form

      expect(page).to have_content 'You have successfully signed up'
    end
  end

  context 'with empty token' do
    it 'should fail' do
      visit organiser_registration_path token: '123'

      fill_in_registration_form

      expect(page).to have_content 'Registration by invitation only'
    end
  end

  context 'with invalid password confirmation' do
    it 'should fail' do
      visit organiser_registration_path token: invitation.token

      fill_in_registration_form password_confirmation: 'wrong'

      expect(page).to_not have_content 'You have successfully signed up'
      expect(page).to have_content 'doesn\'t match Password'
    end
  end

  context 'with duplicate email' do
    it 'should fail' do
      create :user, email: 'jurgen@example.com'
      visit organiser_registration_path token: invitation.token

      fill_in_registration_form email: 'jurgen@example.com'

      expect(page).to_not have_content 'You have successfully signed up'
      expect(page).to have_content 'already in use'
    end
  end
end
