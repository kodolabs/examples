FactoryGirl.define do
  factory :event do
    name { FFaker::Lorem.word }
    begins_on { Time.now }
    ends_on { Time.now + 5.days }
    creator { create :user }
    description { FFaker::Lorem.words }
    agenda { FFaker::Lorem.word }

    trait :active do
      status :active
    end

    trait :pending do
      status :pending
    end

    trait :closed do
      status :closed
    end
  end
end
