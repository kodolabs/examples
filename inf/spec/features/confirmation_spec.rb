require 'rails_helper'

feature 'Confirmation' do
  context 'already confirmed' do
    let(:customer_1) { create(:customer) }
    let(:user_1) { create(:user, customer: customer_1, profile: nil) }

    let(:customer_2) { create(:customer, :with_profile, :declined) }
    let(:user_2) { customer_2.primary_user }

    let(:customer_3) { create(:customer, :with_profile, :approved) }
    let(:user_3) { customer_3.primary_user }
    let(:verification) { create(:verification, :approved, customer: customer_3) }

    let(:customer_4) { create(:customer, :with_active_subscr) }
    let(:user_4) { customer_4.primary_user }
    let(:user_4_account) { create(:account, :facebook, :with_facebook_page, customer: customer_4) }

    specify 'without profile' do
      user_sign_in user_1
      expect(user_1.confirmed?).to be_truthy
      confirm_path = user_confirmation_path(confirmation_token: user_1.confirmation_token)
      visit confirm_path
      expect(current_path).to eq(user_profile_builder_path)
    end

    specify 'without subscription' do
      verification
      user_sign_in user_3
      expect(user_3.confirmed?).to be_truthy
      confirm_path = user_confirmation_path(confirmation_token: user_3.confirmation_token)
      visit confirm_path
      expect(current_path).to eq(user_profile_subscription_path)
    end

    context 'active' do
      let(:confirm_path) { user_confirmation_path(confirmation_token: user_4.confirmation_token) }

      specify 'without connected accounts' do
        user_sign_in user_4
        expect(user_4.confirmed?).to be_truthy
        visit confirm_path
        expect(current_path).to eq(user_accounts_path)
      end

      specify 'with accounts' do
        user_4_account
        user_sign_in user_4
        visit confirm_path
        expect(current_path).to eq(user_dashboard_path)
      end
    end
  end
end
