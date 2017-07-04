require 'rails_helper'

feature 'User' do
  let(:user) { create :user }
  let(:first_event) { create :event, :active, name: 'Best Event', creator: user }
  let(:second_event) { create :event, :active, name: 'Worst Event', creator: user }
  let!(:first_profile) { create :profile, :organiser, surname: 'Axel', user: user, event: first_event }
  let!(:second_profile) { create :profile, :organiser, surname: 'Axel', user: user, event: second_event }

  before { user_sign_in user }

  describe 'events list' do
    before { visit profile_events_path }

    it 'should show in order' do
      events = page.all('.event')
      expect(events[0]).to have_content first_event.name
      expect(events[1]).to have_content second_event.name
    end

    it 'should show one event' do
      click_on first_event.name
      expect(page).to have_content first_event.name
    end
  end
end
