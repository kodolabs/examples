FactoryGirl.define do
  factory :plan do
    name { "Plan #{rand(10_000)}" }
    price_monthly { (rand * 100 + rand * 10).round(2) }
    price_annual { (rand * 100 + rand * 10).round(2) }
    stripe_id_monthly { SecureRandom.hex }
    stripe_id_annual { SecureRandom.hex }
    max_accounts 10
    published true

    trait :unpublished do
      published false
    end
  end
end
