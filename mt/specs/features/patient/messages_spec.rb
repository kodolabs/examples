require 'rails_helper'

feature 'Messages' do
  let(:user)      { create :user }
  let!(:patient)  { create :patient, user: user }
  let(:locations) { create_locations_ancestry('Western Europe', 'Germany', 'Berlin') }
  let!(:hospital) { create :hospital, location: locations.last }

  before { user_sign_in user }

  specify 'Patient can send message to Hospital', :js do
    message = 'Lorem ipsum dolor sit amet'
    reply_message = 'Facilisis turpis magnis'
    reply_to_reply = 'Dignissim porttitor augue ridiculus'

    visit hospital_path(hospital)
    click_on 'Ask a question'

    fill_in 'message[body]', with: message
    click_button 'Send'

    sleep 0.2 # let it store to DB

    # imitate a reply from hospital
    conversation = patient.mailbox.conversations_with(hospital).first
    hospital.reply_to_conversation conversation, reply_message

    expect(page).to have_content 'Message was successfully sent'
    click_on 'here'

    expect(page).to_not have_content 'No messages'

    within '.conversations' do
      expect(page).to have_content hospital.name
    end

    within '.conversation__messages' do
      expect(page).to have_content message
      expect(page).to have_content reply_message
      expect(page).to_not have_content reply_to_reply
    end

    fill_in 'Type your reply here', with: reply_to_reply
    click_on 'Reply'

    within '.conversation__messages' do
      expect(page).to have_content reply_to_reply
    end
  end
end
