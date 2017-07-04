require 'rails_helper'

describe Referral::ManualBalanceUpdate do
  context 'referrer balance' do
    specify 'successfully updated' do
      customer = create :customer
      Referral::ManualBalanceUpdate.new(customer, 150, 'admin').call
      expect(customer.referral_transactions.first.amount).to eq(150)
      expect(customer.referral_transactions.first.message).to eq('admin')
      expect(customer.referral_balance.amount).to eq(150)
      Referral::ManualBalanceUpdate.new(customer, -100, 'admin2').call
      expect(customer.referral_transactions.last.amount).to eq(-100)
      expect(customer.referral_transactions.last.message).to eq('admin2')
      expect(customer.referral_balance.amount).to eq(50)
    end
  end
end
