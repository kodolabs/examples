require 'rails_helper'

feature 'Receptionists' do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active, creator: user }
  let!(:profile) { create :profile, :organiser, name: 'Axel', user: user, event: event }
  let!(:first_receptionist) { create :receptionist, event: event, name: 'Jesse' }
  let!(:second_receptionist) { create :receptionist, event: event, name: 'Walter' }

  before { user.organiser.update_attribute(:eventbrite_token, 'sometoken') }

  describe 'when organiser authorized' do
    before do
      user_sign_in user
      visit profile_event_path(event)
    end

    describe 'invite' do
      it 'should send invite with credentials' do
        click_on 'Receptionists'
        fill_in 'Name', with: 'John Doe'
        fill_in 'Email', with: 'john@doe.com'
        click_button 'Invite'
        expect(page).to have_content 'Invite to receptionist successfully sended'
      end

      it 'should failed with wrong credentials' do
        click_on 'Receptionists'
        fill_in 'Name', with: 'John Doe'
        fill_in 'Email', with: 'john'
        click_button 'Invite'
        expect(page).to have_content 'is invalid'
      end
    end

    describe 'list' do
      before do
        visit profile_event_receptionists_path(event)
      end

      it 'should show in order' do
        receptionists = page.all('.receptionist')
        expect(receptionists[0]).to have_content 'Jesse'
        expect(receptionists[0]).to have_link('', href: first_receptionist.reception_link)

        expect(receptionists[1]).to have_content 'Walter'
        expect(receptionists[1]).to have_link('', href: second_receptionist.reception_link)
      end

      it 'can delete receptionist' do
        receptionists = page.all('.receptionist')
        receptionists[0].find('a.delete-link').click
        expect(page).to have_content 'Receptionist succesfully deleted'
        expect(page).not_to have_content 'Jesse'
      end
    end
  end

  describe 'when organiser not authorized' do
    it 'should see no tab' do
      expect(page).not_to have_link 'Receptionists'
    end
  end
end
