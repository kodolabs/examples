FactoryGirl.define do
  factory :history do
    engaged_users 0
    likes 0
    views 0
    shares 0
    date { FFaker::Time.date }
    period 'day'
    historyable_type 'Page'

    trait :lifetime do
      period 'lifetime'
    end

    trait :days_28 do
      period 'days_28'
    end

    trait :day do
      period 'day'
    end

    trait :post do
      historyable_type 'Post'
    end
  end
end
