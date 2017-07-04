require 'rails_helper'

feature 'Events page' do
  let(:user) { create :user, name: 'Alex', surname: 'Smith' }
  let(:organiser) { create :organiser, user: user }

  let!(:first_event) { create :event, :active, name: 'Best Event', creator: user }
  let!(:second_event) { create :event, :active, name: 'Worst Event', creator: user }

  let(:first_profile) { create :profile, :organiser, surname: 'Axel', user: user, event: first_event }
  let(:second_profile) { create :profile, :organiser, surname: 'Bob', user: user, event: second_event }

  describe 'with signed admin' do
    before do
      admin_sign_in
      visit admin_events_path
    end

    it 'should show in order' do
      events = page.all('.event')
      expect(events[0]).to have_content first_event.name
      expect(events[1]).to have_content second_event.name
    end

    it 'should sorted by name' do
      click_link 'Name'
      events = page.all('.event')
      expect(events[0]).to have_content second_event.name
      expect(events[1]).to have_content first_event.name
    end
  end
end
