require 'rails_helper'

describe User::ProfileBuildersController, type: :controller do
  context 'has profile' do
    let(:show) { get :show }

    context 'without subscription' do
      let(:customer) { create(:customer, :with_profile, :approved) }
      let(:verification) { create(:verification, :approved, customer: customer) }

      let(:user) { customer.primary_user }

      specify 'success' do
        verification
        sign_in user
        expect(show).to redirect_to(user_profile_subscription_path)
      end
    end

    context 'active' do
      let(:customer) { create(:customer, :with_active_subscr) }
      let(:user) { customer.primary_user }
      let(:account) { create(:account, :facebook, :with_facebook_page, customer: customer) }

      specify 'without connected accounts' do
        sign_in user
        expect(show).to redirect_to(user_accounts_path)
      end

      specify 'with accounts' do
        account
        sign_in user
        expect(show).to redirect_to(user_dashboard_path)
      end
    end
  end
end
