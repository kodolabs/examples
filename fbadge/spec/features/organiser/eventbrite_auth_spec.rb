require 'rails_helper'

feature 'Organiser' do
  let!(:user) { create :user, :organiser }
  before { user_sign_in user }

  context 'without eventbrite token' do
    it 'should see auth button' do
      visit root_path
      expect(page).to have_content 'Authorize via Eventbrite'
      expect(page).not_to have_content 'Create Event'
    end
  end

  context 'with eventbrite token' do
    it 'should be successful' do
      user.organiser.update_attribute(:eventbrite_token, 'sometoken')
      visit root_path
      expect(page).to have_content 'Create Event'
      expect(page).not_to have_content 'Authorize via Eventbrite'
    end
  end
end
