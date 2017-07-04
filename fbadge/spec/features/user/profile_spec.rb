require 'rails_helper'

feature 'Profile' do
  let(:user) { create :user, :organiser }
  let(:second_user) { create :user }
  let(:event) { create :event, :active, creator: user }
  let!(:profile) { create :profile, :organiser, name: 'Axel', user: user, event: event }
  let!(:second_profile) { create :profile, :visitor, name: 'Rose', user: second_user, event: event }

  describe 'update with valid credentials' do
    before do
      user_sign_in user
      visit edit_profile_event_profile_path(event)
    end

    it 'should show success message' do
      fill_in 'Name', with: 'John Doe'
      fill_in 'Surname', with: 'john@doe.com'
      fill_in 'Phone', with: '88005553535'
      fill_in 'Company', with: 'New Company'
      click_button 'Update Profile'
      expect(page).to have_content 'Profile successfully updated'
    end

    it 'should show error message' do
      fill_in 'Name', with: ''
      fill_in 'Surname', with: 'john@doe.com'
      fill_in 'Phone', with: '88005553535'
      fill_in 'Company', with: 'New Company'
      click_button 'Update Profile'
      expect(page).to have_content "can't be blank"
    end
  end

  describe 'profile tab without organiser' do
    before do
      user_sign_in second_user
      visit edit_profile_event_profile_path(event)
    end

    it 'should get access' do
      expect(page).to have_content(event.name)
    end
  end
end
