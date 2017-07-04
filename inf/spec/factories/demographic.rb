FactoryGirl.define do
  factory :demographic do
    page
    metric_type 'fans'
    languages {}
    countries {}
    genders {}
    cities {}
    date { FFaker::Time.date }

    trait :engaged do
      metric_type :engaged
    end

    trait :reached do
      metric_type :reached
    end
  end
end
