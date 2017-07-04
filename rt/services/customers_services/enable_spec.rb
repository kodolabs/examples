require 'rails_helper'

describe CustomersServices::Enable do
  let(:customer) { create :customer, suspended_at: 1.day.ago, status: Customer::STATUS_SUSPENDED }

  it 'update status and suspended date' do
    expect(Harvester).to receive(:resume).and_return(true)
    expect(CustomersServices::Enable.new(customer).perform).to match([true, ''])
    expect(customer.status).to eq 'active'
    expect(customer.suspended_at).to be_nil
    expect(customer.errors.empty?).to be_truthy
  end
end
