FactoryGirl.define do
  factory :profile do
    name { FFaker::Name.first_name }
    surname { FFaker::Name.last_name }
    event
    user

    trait :visitor do
      role :visitor
    end

    trait :speaker do
      role :speaker
    end

    trait :organiser do
      role :organiser
    end
  end
end
