FactoryGirl.define do
  factory :alert do
    description { FFaker::Lorem.sentence }
    alertable_type 'Domain'

    trait :deindexed do
      kind { :domain_deindexed }
    end

    trait :reindexed do
      kind { :domain_reindexed }
    end
  end
end
