FactoryGirl.define do
  factory :history do
    monitoring
    created_at { Time.zone.today }

    trait :success do
      status { :success }
    end

    trait :error do
      status { :error }
    end
  end
end
