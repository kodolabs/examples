FactoryGirl.define do
  factory :campaign do
    client
    domain { FFaker::Internet.domain_name }
    contract_period { rand(1..12) }
    brand { :epik }
    started_at { rand(1..12).day.ago }

    trait :inactive do
      active { false }
    end
  end
end
