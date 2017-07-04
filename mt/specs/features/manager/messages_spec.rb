require 'rails_helper'

feature 'Manager messages' do
  let(:manager)   { create :manager }
  let(:user)      { create :user }
  let(:patient)   { create :patient, user: user }
  let!(:hospital) { create :hospital, manager: manager }

  before { manager_sign_in manager }

  context 'view' do
    it 'should show no messages' do
      visit manager_messages_path
      expect(page).to have_content 'No messages'
      expect(page).to have_css 'a.dashboard-nav__link--active', text: 'Messages'
    end
  end

  context 'messaging' do
    specify 'Hospital can exchange messages with patients', :js do
      message = 'Lorem ipsum dolor sit amet'
      reply_message = 'Facilisis turpis magnis'

      # imitate initial message from patient
      patient.send_message hospital, message, 'Subject'

      visit manager_messages_path

      expect(page).to_not have_content 'No messages'

      within '.conversations' do
        expect(page).to have_content patient.name
      end

      within '.conversation__messages' do
        expect(page).to have_content message
      end

      fill_in 'Type your reply here', with: reply_message
      click_on 'Reply'

      within '.conversation__messages' do
        expect(page).to have_content message
        expect(page).to have_content reply_message
      end
    end
  end
end
