require 'rails_helper'

describe 'Demo account' do
  let(:customer) { create(:customer, :with_active_subscr, :demo) }
  let(:user) { customer.primary_user }

  before(:each) { user_sign_in user }

  specify 'disable pages' do
    visit user_accounts_path
    expect(page).to have_css '.accounts-page.disabled'

    visit edit_user_profile_path
    expect(page).to have_css '#profile-page.disabled'

    visit user_profile_subscription_path
    expect(page).to have_css '.subscription-page.disabled'
  end
end
