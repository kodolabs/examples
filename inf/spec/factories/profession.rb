FactoryGirl.define do
  factory :profession do
    title { FFaker::Name.name }

    trait :doctor do
      title 'Doctor'
    end

    trait :nurse do
      title 'Nurse'
    end

    trait :not_active do
      is_active false
    end

    trait :is_active do
      is_active true
    end
  end

  preload do
    factory(:doctor) { create :profession, :doctor, :is_active }
    factory(:nurse) { create :profession, :nurse, :is_active }
  end
end
