FactoryGirl.define do
  factory :topic do
    keyword { SecureRandom.hex }
    trait :speciality do
      speciality true
    end
    trait :sub_speciality do
      sub_speciality true
    end
    trait :interest do
      interest true
    end
  end
end
