require 'rails_helper'

feature 'Twitter accounts' do
  let(:customer) { create :customer, :with_active_subscr, :with_profile }
  let(:user) { customer.primary_user }
  let(:twitter_account) { create :account, :twitter, customer: customer, username: 'twitteruser' }

  before(:each) { user_sign_in user }

  specify 'connect' do
    visit user_accounts_path
    expect(page).to have_css "form[action='/auth/twitter']"
  end

  specify 'disconnect' do
    twitter_account
    visit user_accounts_path
    expect(page).to have_content twitter_account.name
    click_on 'Disconnect'
    expect(page).to have_flash 'Account was disconnected'
    expect(page).not_to have_content twitter_account.name
  end
end
