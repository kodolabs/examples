require 'rails_helper'

describe 'StripeService::Subscription' do
  before(:all) { StripeMock.start }
  after(:all) { StripeMock.stop }

  describe '#process_event' do
    context 'when charge.succeeded' do
      let!(:customer) { create(:customer, :with_inactive_subscr) }
      let!(:referral) do
        create(
          :referral,
          referral: customer,
          referrer: create(:customer, :with_active_subscr)
        )
      end
      let!(:plan) { create :plan }
      let!(:event_type) { 'charge.succeeded' }
      let!(:object_data) do
        StripeMock.mock_webhook_event(
          'charge.succeeded',
          customer: customer.stripe_id
        )[:data][:object]
      end
      let!(:invoice_data) do
        { period: { end: (Time.current.utc + 1.month).to_i }, plan: { id: plan.stripe_id_annual } }
      end
      let(:renew_result) do
        StripeService::Subscription.new(customer).process_event(event_type, object_data)
      end

      before do
        expect_any_instance_of(StripeService::Subscription)
          .to(receive(:invoice_subscr).and_return(invoice_data))
      end

      def expect_referral_balance_update
        expect_any_instance_of(Referral::AutomaticalBalanceUpdate)
          .to(receive(:call)).and_return(true)
      end

      it 'should update subscription end date' do
        expect_referral_balance_update
        expect(customer.valid_subscription?).to eq false
        renew_result
        expect(customer.reload.valid_subscription?).to eq true
      end

      it 'should create payment' do
        expect_referral_balance_update
        renew_result
        payments = customer.subscription.payments
        expect(payments.count).to eq 1
        expect(payments.first.amount).to eq(object_data[:amount].to_f / 100)
        expect(payments.first.description).to eq plan.decorate.name_with_price_for(plan.stripe_id_annual)
      end
    end

    context 'when customer.subscription.deleted' do
      let!(:customer) { create(:customer, :with_active_subscr) }
      let!(:event_type) { 'customer.subscription.deleted' }

      it 'should drop subscription end date' do
        expect(customer.valid_subscription?).to eq true
        StripeService::Subscription.new(customer).process_event(event_type, {})
        expect(customer.reload.valid_subscription?).to eq false
      end
    end
  end
end
