require 'rails_helper'

describe CustomersServices::Cancel do
  context 'for user without subscription' do
    let(:customer) { create :customer }
    let(:service) { CustomersServices::Cancel.new customer, customer.subscription }
    it 'return true' do
      expect(service.perform).to eq [true, '']
    end

    it 'set user as cancelled date' do
      expect { service.perform }.to change { customer.canceled_at }
    end

    it 'set user status as cancelled' do
      expect { service.perform }.to change { customer.status }
    end
  end

  context 'for user with subscription', braintree: true do
    let(:customer) { create :customer, :with_pro_subscription }
    let(:service) { CustomersServices::Cancel.new customer, customer.subscription }
    it '' do
      transaction = double(id: 'some_id', amount: 100.0, created_at: 1.minute.ago)
      subscription = double(transactions: [transaction, transaction], status_history: [double(balance: -200.0), double(balance: -100.0)])
      allow_any_instance_of(BraintreeService).to receive(:update_subscription).and_return([true, subscription])
      allow_any_instance_of(BraintreeService).to receive(:cancel_subscription).and_return(true)
      expect(service.perform).to eq [true, '']
    end
  end
end
