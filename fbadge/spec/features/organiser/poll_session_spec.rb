require 'rails_helper'

feature 'Poll Sessions' do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active, creator: user }
  let!(:profile) { create :profile, :organiser, user: user, event: event }
  let!(:poll) { create :poll, event: event }
  let!(:poll_session) { create :poll_session, poll: poll }
  let!(:first_answer) { create :answer, poll: poll, position: 1 }
  let!(:second_answer) { create :answer, poll: poll, position: 2 }
  let!(:qrcodes_dir) { "#{Rails.root}/public/system/test/images/polls/".freeze }

  before do
    user.organiser.update_attribute(:eventbrite_token, 'sometoken')
    user_sign_in user
  end

  describe 'active' do
    it 'should change status to closed' do
      visit profile_event_poll_path(event, poll)
      click_link 'Close Session'
      expect(page).to have_content 'Session succesfully closed'
    end
  end
end
