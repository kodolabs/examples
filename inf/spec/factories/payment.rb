FactoryGirl.define do
  factory :payment do
    subscription
    created_at { (subscription.ends_at || Time.current.utc + 2.months) - 1.month }
    amount 9.99
    description { subscription.plan.decorate.name_with_price_for(subscription.plan.stripe_id_annual) }
  end
end
