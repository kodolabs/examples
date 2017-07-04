require 'rails_helper'

describe Referral::CreateRegistration do
  context 'referral registration' do
    specify 'successfully created' do
      referrer = create :customer
      referral = create :customer
      Referral::CreateRegistration.new(referral, referrer.referral_code).call
      expect(Referral.count).to eq(1)
    end
  end
end
