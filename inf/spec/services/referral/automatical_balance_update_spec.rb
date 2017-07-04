require 'rails_helper'

describe Referral::AutomaticalBalanceUpdate do
  context 'referrer and referral balance' do
    specify 'successfully updated' do
      referrer = create(:customer, :with_active_subscr)
      registration = create(:referral, referrer: referrer)
      Referral::AutomaticalBalanceUpdate.new(registration).call
      expect(ReferralTransaction.count).to eq(2)
      referrer.reload
      referral = registration.referral
      expect(referrer.referral_balance.amount).to eq Setting['referral_program.referrer_amount']
      expect(referral.referral_balance.amount).to eq Setting['referral_program.referral_amount']
    end
  end
end
