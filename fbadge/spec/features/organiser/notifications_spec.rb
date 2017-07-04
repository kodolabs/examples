require 'rails_helper'

feature 'Notifications' do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active, creator: user }
  let(:profile) { create :profile, :organiser, name: 'Axel', user: user, event: event }
  let!(:first_notification) { create :notification, event: event, sender: profile, created_at: Time.now }
  let!(:second_notification) { create :notification, event: event, sender: profile, created_at: Time.now + 1.minute }

  before { user.organiser.update_attribute(:eventbrite_token, 'sometoken') }

  describe 'when organiser authorized' do
    before do
      user_sign_in user
      visit profile_event_notifications_path(event)
    end

    describe 'list' do
      it 'should show in order' do
        notifications = page.all('.notification')
        expect(notifications[0]).to have_content second_notification.title
        expect(notifications[1]).to have_content first_notification.title
      end
    end
  end

  describe 'when organiser not authorized' do
    it 'should see no tab' do
      expect(page).not_to have_link 'Receptionists'
    end
  end
end
