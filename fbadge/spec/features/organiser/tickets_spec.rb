require 'rails_helper'

feature 'Tickets' do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active, name: 'Best Event', creator: user }
  let!(:profile1) { create :profile, :organiser, surname: 'Axel', user: user, event: event }
  let!(:profile2) { create :profile, :organiser, surname: 'Rose', user: user, event: event }
  let!(:ticket_class) { create :ticket_class, event: event }
  let!(:ticket1) { create :ticket, profile: profile1, ticket_class: ticket_class, barcode: 'first', created_at: Time.now }
  let!(:ticket2) { create :ticket, profile: profile2, ticket_class: ticket_class, barcode: 'second', created_at: Time.now - 1.day }

  before { user_sign_in user }

  describe 'list' do
    before { visit profile_event_path(event) }

    it 'should show in order' do
      click_on 'Tickets'
      tickets = page.all('.ticket')
      expect(tickets[0]).to have_content profile1.surname
      expect(tickets[1]).to have_content profile2.surname
    end
  end
end
