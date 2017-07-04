FactoryGirl.define do
  factory :referral_transaction do
    customer
    message { FFaker::Name.name }
    amount { rand(-100...100) }
  end
end
