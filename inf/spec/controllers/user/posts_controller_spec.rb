require 'rails_helper'

describe User::PostsController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  let(:post) { create(:post) }

  context 'create' do
    specify 'success' do
      sign_in(user)
      allow_any_instance_of(CreatePostWorker).to receive(:perform)
      expect_any_instance_of(CreatePostWorker).to receive(:perform).once.and_return(post)
      get :create, params: { uid: '123', page_uid: '789' }
      expect(response.status).to eq 200
    end
  end
end
