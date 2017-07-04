require 'rails_helper'

describe 'StripeService::Event' do
  before(:all) { StripeMock.start }
  after(:all) { StripeMock.stop }

  it 'should return :bad_request on malicious event' do
    expect(StripeService::Event.new(id: '').process).to eq :bad_request
  end

  it 'should return :ok for irrelevant event' do
    data = StripeMock.mock_webhook_event('account.updated')
    expect(StripeService::Event.new(data).process).to eq(:ok)
  end

  context 'when success payment' do
    let!(:customer) { create(:customer, :with_inactive_subscr) }
    let!(:data) do
      StripeMock.mock_webhook_event(
        'charge.succeeded',
        customer: customer.stripe_id
      )
    end

    it 'should renew subscription' do
      expect_any_instance_of(StripeService::Subscription).to receive(:renew).and_return(true)
      StripeService::Event.new(data).process
    end
  end

  context 'when subscription deleted' do
    let!(:customer) { create(:customer, :with_active_subscr) }
    let!(:data) do
      StripeMock.mock_webhook_event(
        'customer.subscription.deleted',
        customer: customer.stripe_id
      )
    end

    it 'should disable subscription' do
      expect_any_instance_of(StripeService::Subscription).to receive(:remove).and_return(true)
      StripeService::Event.new(data).process
    end
  end
end
