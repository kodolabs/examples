require 'rails_helper'

feature Vote do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active, creator: user }
  let!(:profile) { create :profile, :organiser, user: user, event: event }
  let!(:poll) { create :poll, event: event }
  let!(:poll_session) { create :poll_session, poll: poll, status: 'closed' }
  let!(:first_answer) { create :answer, poll: poll, position: 1 }
  let!(:second_answer) { create :answer, poll: poll, position: 2 }
  let!(:qrcodes_dir) { "#{Rails.root}/public/system/test/images/polls/".freeze }
  let!(:ticket_class) { create :ticket_class, event: event }
  let!(:badge) { create :badge }
  let!(:ticket) { create :ticket, ticket_class: ticket_class, profile: profile }
  let!(:registration) { create :registration, badge: badge, profile: profile, ticket: ticket, event: event }

  describe 'for closed poll session' do
    it "can't be created" do
      vote = Vote.new
      vote.registration = registration
      vote.poll_session = poll_session
      vote.valid?
      vote.errors[:poll_session].should include('is not active')
    end
  end
end
