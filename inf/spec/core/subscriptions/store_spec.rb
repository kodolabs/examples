require 'rails_helper'

describe Subscriptions::Store do
  before(:all) { StripeMock.start }
  after(:all) { StripeMock.stop }

  let(:service) { Subscriptions::Store }
  let(:stripe_helper) { StripeMock.create_test_helper }

  context 'create' do
    let(:customer) { create(:customer) }
    let(:user) { create(:user, customer: customer) }
    let(:plan) do
      plan = create(:plan)
      stripe_helper.create_plan(id: plan.stripe_id_annual, amount: 9999)
      plan
    end
    let!(:card) do
      create(:card, customer: customer, stripe_token: stripe_helper.generate_card_token, default: true)
    end

    it 'should create subscription' do
      service.call(customer, plan.id, 'year')
      subscription = customer.subscription
      expect(subscription.plan_id).to eq plan.id
      stripe_subscr = Stripe::Subscription.retrieve(subscription.stripe_id)
      expect(stripe_subscr.plan.id).to eq plan.stripe_id_annual
    end
  end

  context 'update' do
    let(:customer) do
      customer = create(:customer, :with_new_subscr)
      token = stripe_helper.generate_card_token
      create(:card, customer: customer, stripe_token: token)
      stripe_helper.create_plan(id: customer.stripe_plan_id, amount: 999)
      Subscriptions::Store.call(customer, customer.plan.id, 'year')
      customer.reload
      customer
    end

    let(:subscription) { customer.subscription }

    let(:old_plan) { customer.plan }
    let(:new_plan) do
      plan = create :plan
      stripe_helper.create_plan(id: plan.stripe_id_monthly, amount: 9999)
      plan
    end

    it 'should not change plan if accounts limit overrun' do
      new_plan.update_attribute(:max_accounts, 0)
      service.call(customer, new_plan.id, 'month')
      subscription.reload
      expect(subscription.plan).to eq old_plan
    end

    it 'should change plan' do
      # binding.pry
      service.call(customer, new_plan.id, 'month')
      subscription.reload
      expect(subscription.plan_id).to eq new_plan.id
      stripe_subscr = Stripe::Subscription.retrieve(subscription.stripe_id)
      expect(stripe_subscr.plan.id).to eq new_plan.stripe_id_monthly
    end
  end
end
