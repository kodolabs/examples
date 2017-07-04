FactoryGirl.define do
  factory :subscription do
    customer
    plan
    stripe_id nil
    ends_at nil
    period 'year'

    trait :active do
      stripe_id { SecureRandom.hex }
      ends_at   { Time.current.utc + 1.month }
    end

    trait :inactive do
      stripe_id { SecureRandom.hex }
      ends_at   { Time.current.utc - 15.days }
    end
  end
end
