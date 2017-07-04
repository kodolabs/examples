require 'rails_helper'

feature 'Subscription update' do
  before(:all) { StripeMock.start }
  after(:all) { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let!(:first_plan) do
    plan = create(:plan)
    stripe_helper.create_plan(id: plan.stripe_id_annual)
    stripe_helper.create_plan(id: plan.stripe_id_monthly)
    plan
  end
  let!(:second_plan) do
    plan = create(:plan)
    stripe_helper.create_plan(id: plan.stripe_id_annual)
    stripe_helper.create_plan(id: plan.stripe_id_monthly)
  end
  let(:token) { stripe_helper.generate_card_token }
  let!(:customer) { create(:customer, :with_profile, :approved, :verified) }
  let!(:user) { customer.primary_user }
  let!(:subscription) { create(:subscription, customer: customer, plan: first_plan) }
  let!(:card) { create(:card, customer: customer, stripe_token: token, default: true) }

  specify 'User can update plan' do
    Subscriptions::Store.call(customer, customer.plan.id, 'year')
    user_sign_in user
    visit user_profile_subscription_path
    first(:link, 'Update').click
    expect(page).to have_flash I18n.t('subscription.plan_updated')
  end
end
