require 'rails_helper'

feature 'Referrals' do
  let(:admin) { create :admin }

  context 'when admin logged in' do
    before { admin_sign_in admin }

    it 'can see list of referrals' do
      customer = create(:customer, :with_active_subscr)
      referral = create(:customer, :with_active_subscr)
      create(:referral, referrer: customer, referral: referral)
      visit admin_referrals_path
      expect(page).to have_content customer.decorate.full_name
      expect(page).to have_content customer.referrals.count
      click_on customer.decorate.full_name
      expect(page).to have_content 'Transaction History'
    end
  end
end
