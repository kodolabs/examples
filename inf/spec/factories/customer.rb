FactoryGirl.define do
  factory :customer do
    status :pending
    demo false

    trait :with_user do
      after(:create) do |customer, _evaluator|
        create(:user, customer: customer)
      end
    end

    trait :with_feed do
      after(:create) do |customer, _evaluator|
        create(:feed, customer: customer)
      end
    end

    trait :with_new_subscr do
      after(:create) do |customer, _evaluator|
        create(:user, customer: customer)
        create(:subscription, customer: customer)
      end
    end

    trait :with_active_subscr do
      approved
      with_profile

      after(:create) do |customer, _evaluator|
        customer.primary_user || create(:user, customer: customer)
        create(:verification, :approved, customer: customer)
        create(:subscription, :active, customer: customer)
      end
    end

    trait :with_inactive_subscr do
      after(:create) do |customer, _evaluator|
        create(:user, customer: customer)
        create(:subscription, :inactive, customer: customer)
      end
    end

    trait :with_topics do
      after(:create) do |customer|
        u = customer.primary_user || create(:user, customer: customer)
        u.profile.topics << create(:topic)
      end
    end

    trait :with_profile do
      after(:create) do |customer, _evaluator|
        user = customer.primary_user || create(:user, customer: customer)
        create(:profile, user: user)
        create(:card, customer: customer)
      end
    end

    trait :approved do
      status :approved
    end

    trait :declined do
      status :declined
    end

    trait :verified do
      after(:create) do |customer, _evaluator|
        create(:verification, :approved, customer: customer)
      end
    end

    trait :demo do
      demo true
      demo_token { SecureRandom.hex }
    end

    trait :nearly_notified do
      notified_at { Time.zone.now - 2.hours }
    end

    trait :old_notified do
      notified_at { Time.zone.now - 2.years }
    end

    trait :with_trial do
      trial_ends_on { Time.zone.now + 2.days }
    end

    trait :expired_trial do
      trial_ends_on { Time.zone.now - 2.days }
    end
  end
end
