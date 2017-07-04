require 'rails_helper'

describe DemoController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr, :demo) }
  let(:user) { customer.primary_user }
  let(:customer2) { create(:customer, :with_inactive_subscr, :demo, :with_profile, :approved, :verified) }

  context 'login' do
    specify 'success' do
      customer
      get :login, params: { token: customer.demo_token }
      expect(response).to redirect_to(user_accounts_path)
    end

    specify 'fail' do
      get :login, params: { token: 'aa' }
      expect(response.status).to eq(404)
    end

    specify 'without subscription' do
      customer2
      get :login, params: { token: customer2.demo_token }
      expect(response).to redirect_to(user_profile_subscription_path)
    end
  end
end
