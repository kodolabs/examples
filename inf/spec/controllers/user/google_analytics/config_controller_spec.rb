require 'rails_helper'

describe User::GoogleAnalytics::ConfigController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  let(:account) { create(:account, :google, customer: customer) }
  let(:config_service) { GoogleAnalytics::Configuration }
  before(:each) { sign_in(user) }
  context 'success' do
    specify 'views' do
      sign_in(user)
      allow_any_instance_of(config_service).to receive(:call)
      allow_any_instance_of(config_service).to receive(:views).and_return([])
      expect_any_instance_of(config_service).to receive(:call).once
      get :views, params: { id: account.id }, xhr: true
      expect(response.status).to eq(200)
      res = { 'views' => [] }
      expect(JSON.parse(response.body)).to eq(res)
    end

    specify 'update' do
      sign_in(user)
      form_params = { account_name: 'cc', uid: 'aa', account_uid: 'bb' }
      post :update, params: { id: account.id, config: form_params }
      expect(response).to redirect_to(user_accounts_path)
      expect(AnalyticsConfig.count).to be > 0
    end
  end
end
