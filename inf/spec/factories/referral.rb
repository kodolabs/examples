FactoryGirl.define do
  factory :referral do
    referrer { create(:customer, :with_active_subscr) }
    referral { create(:customer, :with_active_subscr) }
  end
end
