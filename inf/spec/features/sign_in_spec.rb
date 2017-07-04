require 'rails_helper'

feature 'Sign in' do
  context 'menu' do
    context 'dashboard' do
      let(:customer) { create(:customer, :with_profile, :with_active_subscr) }
      let(:user) { customer.primary_user }
      let(:account) { create(:account, :with_facebook_page, customer: customer) }
      let(:page_1) { account.pages.last }
      let(:account_2) { create(:account, :facebook, customer: customer) }

      specify 'accounts' do
        account_2
        user_sign_in user
        expect(page).to have_current_path(user_accounts_path)
      end

      specify 'dashboard' do
        page_1
        user_sign_in user
        expect(page).to have_current_path(user_dashboard_path)
        expect(page).to have_content 'Dashboard'
        expect(page).not_to have_content 'Back to admin'
      end
    end
  end

  context 'without profile' do
    let(:customer) { create(:customer) }
    let(:user) { create(:user, customer: customer, profile: nil) }

    specify 'success' do
      user_sign_in user
      expect(current_path).to eq(user_profile_builder_path)
      user_links = [
        user_dashboard_path, user_new_post_path, user_schedule_path,
        user_facebook_analytics_path, user_my_feeds_path, user_social_magnet_path,
        user_campaigns_path, user_news_magnet_path, user_referrals_path
      ]

      user_links.each do |link|
        visit link
        expect(current_path).to eq(user_profile_builder_path)
      end
    end
  end

  context 'trial' do
    let(:customer) { create(:customer, :with_profile, :with_trial) }
    let(:user) { customer.primary_user }

    let(:customer2) { create(:customer, :with_profile, :expired_trial) }
    let(:user2) { customer2.primary_user }

    specify 'new user' do
      user_sign_in user
      expect(page).not_to have_content 'Please upload your documents'
      expect(current_path).to eq(user_accounts_path)
    end

    specify 'expired' do
      user_sign_in user2
      expect(page).to have_content 'Please upload your documents'
    end
  end

  context 'without subscription' do
    let(:customer) { create(:customer, :with_profile, :approved) }
    let(:verification) { create(:verification, :approved, customer: customer) }

    let(:user) { customer.primary_user }

    specify 'success' do
      verification
      user_sign_in user
      expect(current_path).to eq(user_profile_subscription_path)
    end
  end

  context 'active' do
    let(:customer) { create(:customer, :with_active_subscr, :with_profile) }
    let(:user) { customer.primary_user }
    let(:account) { create(:account, :facebook, :with_facebook_page, customer: customer) }

    specify 'without connected accounts' do
      user_sign_in user
      expect(current_path).to eq(user_accounts_path)
    end

    specify 'with accounts' do
      account
      user_sign_in user
      expect(current_path).to eq(user_dashboard_path)
    end
  end

  context 'disabled' do
    let(:customer) { create(:customer, :with_active_subscr, :with_profile, active: false) }
    let(:user) { customer.primary_user }

    specify 'success' do
      user_sign_in user
      expect(current_path).to eq(new_user_session_path)
      expect(page).to have_flash 'You account has been disabled, please contact to administrator'
    end
  end
end
