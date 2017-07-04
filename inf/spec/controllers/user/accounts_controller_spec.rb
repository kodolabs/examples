require 'rails_helper'
require 'google/apis/analytics_v3'

describe User::AccountsController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  let(:account) { create(:account, customer: customer) }
  let(:google_account) { create(:account, :google, customer: customer) }

  context 'google', :stub_facebook do
    let(:config_service) { GoogleAnalytics::Configuration }

    context 'already connected' do
      context 'errors' do
        specify 'auth error' do
          allow_any_instance_of(config_service).to receive(:call)
            .and_raise(Google::Apis::AuthorizationError.new('123'))
          sign_in(user)
          google_account
          get :index
          expect(response.status).to eq(200)
          expect(assigns(:banners).first[:text]).to include 'Reconnect your Google account'
        end

        specify 'unknown error' do
          allow_any_instance_of(config_service).to receive(:call).and_raise('aa')
          sign_in(user)
          google_account
          get :index
          expect(response.status).to eq(200)
          expect(flash[:error]).to include 'Unknown error'
        end
      end
    end
  end
end
