require 'rails_helper'

feature 'Subscription create' do
  before(:all) { StripeMock.start }
  after(:all) { StripeMock.stop }
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:token) { stripe_helper.generate_card_token }
  let!(:plan) do
    plan = create(:plan)
    stripe_helper.create_plan(id: plan.stripe_id_annual)
    stripe_helper.create_plan(id: plan.stripe_id_monthly)
  end
  let(:customer) { create(:customer, :with_profile, :approved, :verified) }
  let(:user) { customer.primary_user }
  let!(:card) { create(:card, customer: customer, stripe_token: token, default: true) }

  specify 'User can create plan' do
    user_sign_in user
    visit user_profile_subscription_path
    within '.subscr-plans' do
      first(:link, 'Select').click
    end
    expect(page).to have_flash I18n.t('subscription.plan_created')
  end
end
