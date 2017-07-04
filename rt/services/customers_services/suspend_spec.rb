require 'rails_helper'

describe CustomersServices::Suspend do
  let(:customer) { create :customer }

  it 'update status and suspended date' do
    expect(Harvester).to receive(:pause).and_return(true)
    expect(CustomersServices::Suspend.new(customer).perform).to match([true, ''])
    expect(customer.status).to eq 'suspended'
    expect(customer.suspended_at.to_date).to eq Time.zone.now.to_date
    expect(customer.errors.empty?).to be_truthy
  end
end
