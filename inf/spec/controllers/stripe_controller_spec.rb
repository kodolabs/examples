require 'rails_helper'

describe StripeController, type: :controller do
  before(:all) { StripeMock.start }
  after(:all) { StripeMock.stop }

  it 'should fail on malicious requests' do
    post :webhooks, body: { id: '' }.to_json
    expect(response.status).to eq 400
  end

  it 'should ignore irrelevant event types' do
    data = StripeMock.mock_webhook_event('account.updated')
    post :webhooks, body: data.to_json
    expect(response.status).to eq 200
  end

  it 'should process relevant event types' do
    customer = create(:customer, :with_inactive_subscr)
    data = StripeMock.mock_webhook_event(
      'invoice.payment_succeeded', customer: customer.stripe_id
    )

    post :webhooks, body: data.to_json
    expect(response.status).to eq 200
  end
end
