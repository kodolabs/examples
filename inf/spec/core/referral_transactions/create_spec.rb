require 'rails_helper'

describe ReferralTransactions::Create do
  let!(:customer) { create :customer }
  let(:form) do
    ReferralTransactions::ReferralTransactionForm.from_params(
      amount: 100,
      message: 'admin'
    )
  end

  it 'should create referral transaction' do
    expect_any_instance_of(ReferralTransactions::Create).to(
      receive(:customer_id).and_return(customer.id)
    )
    ReferralTransactions::Create.new(form).call
    expect(customer.referral_transactions.first.amount).to eq(100)
    expect(customer.referral_transactions.first.message).to eq('admin')
    customer.reload
    expect(customer.referral_balance.amount).to eq(100)
  end
end
