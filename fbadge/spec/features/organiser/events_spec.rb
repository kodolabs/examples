require 'rails_helper'

feature 'Organiser' do
  let(:user) { create :user, :organiser }
  let!(:first_event) { create :event, :active, name: 'Best Event', creator: user }
  let!(:second_event) { create :event, :active, name: 'Worst Event', creator: user }
  let!(:third_event) { create :event, :active, name: 'Visitor Event' }
  let!(:first_profile) { create :profile, :organiser, surname: 'Axel', user: user, event: first_event }
  let!(:second_profile) { create :profile, :organiser, surname: 'Axel', user: user, event: second_event }
  let!(:third_profile) { create :profile, :visitor, surname: 'Rousy', user: user, event: third_event }

  describe 'have access' do
    before do
      user_sign_in user
      user.organiser.update_attribute(:eventbrite_token, 'sometoken')
    end

    it 'can create an event', js: true do
      visit new_profile_event_path
      fill_in 'Name', with: 'Some event'
      page.execute_script("$('#event_begins_on').val('#{DateTime.now.to_date}')")
      page.execute_script("$('#event_ends_on').val('#{(DateTime.now + 1.day).to_date}')")
      page.execute_script("$('#event_agendas_attributes_0_date').val('#{(DateTime.now + 1.day).to_date}')")
      fill_in 'event_agendas_attributes_0_title', with: 'Some Title'
      fill_in 'event_agendas_attributes_0_description', with: 'Some description'
      click_button 'Create Event'
      expect(page).to have_content 'Event successfully created'
    end

    it 'can not create an event without required attributes' do
      visit new_profile_event_path
      fill_in 'Name', with: 'Some event'
      click_button 'Create Event'
      expect(page).to have_content "can't be blank"
    end

    it 'can not create an event with uncorreted dates', js: true do
      visit new_profile_event_path
      fill_in 'Name', with: 'Some event'
      page.execute_script("$('#event_begins_on').val('#{(DateTime.now - 1.day).to_date}')")
      page.execute_script("$('#event_ends_on').val('#{(DateTime.now - 2.days).to_date}')")
      click_button 'Create Event'
      expect(page).to have_content "can't be in the past"
      expect(page).to have_content "can't be earlier then begins on"
    end

    it 'can update an event', js: true do
      visit edit_profile_event_path(first_event)
      fill_in 'Name', with: 'Some event'
      page.execute_script("$('#event_begins_on').val('#{DateTime.now.to_date}')")
      page.execute_script("$('#event_ends_on').val('#{(DateTime.now + 1.day).to_date}')")
      click_button 'Update Event'
      expect(page).to have_content 'Event successfully updated'
    end

    it 'can delete an event' do
      visit edit_profile_event_path(first_event)
      click_on 'Delete'
      expect(page).to have_content 'Event successfully deleted'
    end

    describe 'events list' do
      before { visit profile_events_path }

      it 'should show in order' do
        events = page.all('#as_organiser .event')
        expect(events[0]).to have_content first_event.name
        expect(events[1]).to have_content second_event.name
      end

      it 'should show one event' do
        click_on first_event.name
        expect(page).to have_content first_event.name
      end

      it 'should show tabs' do
        expect(page).to have_content 'As Visitor'
        expect(page).to have_content 'As Organiser'
      end
    end
  end

  describe 'not have access to event' do
    before do
      user_sign_in user
      visit profile_event_path(third_event)
    end

    it 'should not to have tabs' do
      expect(page).not_to have_content 'Receptionists'
      expect(page).not_to have_content 'Registrations'
      expect(page).not_to have_content 'Ticket Classes'
      expect(page).not_to have_content 'Polls'
    end

    it 'should show error message on edit' do
      visit edit_profile_event_path(third_event)
      expect(page).to have_content 'You are not authorized for this action'
    end

    it 'should show error message on ticket classess' do
      visit profile_event_ticket_classes_path(third_event)
      expect(page).to have_content 'You are not authorized for this action'
    end

    it 'should show error message on ticket classess' do
      visit profile_event_tickets_path(third_event)
      expect(page).to have_content 'You are not authorized for this action'
    end

    it 'should show error message on receptionists' do
      visit profile_event_receptionists_path(third_event)
      expect(page).to have_content 'You are not authorized for this action'
    end

    it 'should show error message on registrations' do
      visit profile_event_registrations_path(third_event)
      expect(page).to have_content 'You are not authorized for this action'
    end

    it 'should show error message on registrations' do
      visit profile_event_polls_path(third_event)
      expect(page).to have_content 'You are not authorized for this action'
    end
  end
end
