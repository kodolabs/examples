require 'rails_helper'

feature 'Ticket Classes' do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active, name: 'Best Event', creator: user }
  let!(:profile) { create :profile, :organiser, surname: 'Axel', user: user, event: event }
  let!(:first_ticket_class) { create :ticket_class, event: event, eventbrite_id: '1' }
  let!(:second_ticket_class) { create :ticket_class, event: event, eventbrite_id: '2' }

  before { user_sign_in user }

  describe 'list' do
    before { visit profile_event_path(event) }

    it 'should show in order' do
      click_on 'Ticket Classes'
      ticket_classes = page.all('.ticket-class')
      expect(ticket_classes[0]).to have_content first_ticket_class.name
      expect(ticket_classes[1]).to have_content second_ticket_class.name
    end
  end
end
