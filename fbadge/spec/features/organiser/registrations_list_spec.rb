require 'rails_helper'

feature 'Organiser registrations' do
  let(:user) { create :user, :organiser }
  let!(:event) { create :event, :active, creator: user }
  let(:ticket_class) { create :ticket_class, event: event }
  let(:first_profile) { create :profile, :organiser, surname: 'Alex', user: user, event: event }
  let(:first_ticket) { create :ticket, profile: first_profile, ticket_class: ticket_class }
  let!(:first_registration) { create :registration, event: event, profile: first_profile, ticket: first_ticket }
  let(:second_profile) { create :profile, :organiser, surname: 'Alex', user: user, event: event }
  let(:second_ticket) { create :ticket, profile: second_profile, ticket_class: ticket_class }
  let!(:second_registration) { create :registration, event: event, profile: second_profile, ticket: second_ticket }

  context 'list' do
    before do
      user_sign_in user
      visit profile_event_path(event)
      click_on 'Registrations'
    end

    it 'should show in order' do
      registrations = page.all('.registration')
      expect(registrations[0]).to have_content second_profile.name
      expect(registrations[1]).to have_content first_profile.name
    end

    it 'should set canceled status' do
      page.click_link('', href: profile_event_registration_cancel_path(event, first_registration))
      expect(page).to have_content 'Registration successfully canceled'
      expect(page).not_to have_link '', href: profile_event_registration_cancel_path(event, first_registration)
    end
  end
end
