FactoryGirl.define do
  factory :client do
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    phone { FFaker::PhoneNumber.phone_number }
    since { 1.year.ago }
    manager { create :user }
    notes { FFaker::Lorem.sentence }

    trait :inactive do
      active { false }
    end
  end
end
