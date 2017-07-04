FactoryGirl.define do
  factory :task do
    signature { FFaker::Lorem.word }
    due_date { Time.zone.now }

    trait :pending do
      status { :pending }
    end

    trait :payment do
      category { :payment }
    end

    trait :deindexed do
      category { :deindexed }
    end

    trait :uptime do
      category { :uptime }
    end

    trait :hacked do
      category { :hacked }
    end
  end
end
