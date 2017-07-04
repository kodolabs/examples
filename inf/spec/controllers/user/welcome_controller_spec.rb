require 'rails_helper'

describe User::WelcomeController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  context 'success' do
    specify 'index' do
      sign_in(user)
      get :index, params: {}, session: { show_welcome_screen: true }
      expect(response.status).to eq(200)
      expect(@request.session['show_welcome_screen']).to be_falsey
    end
  end

  context 'fail' do
    specify 'from direct link' do
      sign_in(user)
      get :index
      expect(response.status).to eq(404)
    end
  end
end
