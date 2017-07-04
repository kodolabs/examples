require 'rails_helper'

describe Api::PollSessionsController do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active, creator: user }
  let!(:poll) { create :poll, event: event }

  describe 'POST #create' do
    context 'with poll' do
      it 'saves the new poll session in the database' do
        expect do
          post :create, params: { id: poll.id }
        end.to change(PollSession, :count).by(1)
      end
    end

    context 'with wrong poll id' do
      it 'does not save the new poll session in the database' do
        expect do
          post :create, params: { id: 100_500 }
        end.to change(PollSession, :count).by(0)
        assert_response 400
      end
    end
  end

  describe 'GET #show' do
    context 'with poll' do
      it 'should get result of poll session' do
        poll_session = create :poll_session, poll: poll, status: :active
        get :show, params: { poll_session_id: poll_session.id }
        assert_response :success
      end
    end
  end

  describe 'POST #update' do
    context 'with poll' do
      it "should change status to 'closed' for poll session" do
        active_poll_session = create :poll_session, poll: poll, status: :active
        post :update, params: { poll_session_id: active_poll_session.id }
        active_poll_session.reload
        assert_equal 'closed', active_poll_session.status
        assert_response :success
      end

      it "should not change status to 'closed' when already closed" do
        closed_poll_session = create :poll_session, poll: poll, status: :closed
        post :update, params: { poll_session_id: closed_poll_session.id }
        assert_response 400
      end
    end
  end
end
