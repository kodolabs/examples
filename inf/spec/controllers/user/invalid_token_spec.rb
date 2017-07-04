require 'rails_helper'

describe User::AggregatesController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }

  before(:each) { sign_in(user) }

  context 'success' do
    def invalid_account(provider)
      create(:account, provider, :with_invalid_token, customer: customer)
    end

    let(:fb_account) { invalid_account :facebook }
    let(:twitter_account) { invalid_account :twitter }
    let(:google_account) { invalid_account :google }

    specify 'one account broken' do
      fb_account
      get :content_magnet
      expect(assigns(:banners).first[:text]).to include 'Reconnect your Facebook account'
    end

    specify 'multiple accounts broken' do
      fb_account
      google_account
      twitter_account
      get :content_magnet
      expect(assigns(:banners).first[:text]).to include 'Reconnect your Facebook, Google, Twitter accounts'
    end
  end

  context 'fail' do
    specify 'no accounts' do
      get :content_magnet
      expect(assigns(:banners)).to be_blank
    end

    specify 'with valid tokens' do
      create(:account, :facebook, customer: customer)
      get :content_magnet
      expect(assigns(:banners)).to be_blank
    end
  end
end
