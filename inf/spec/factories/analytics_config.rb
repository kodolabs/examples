FactoryGirl.define do
  factory :analytics_config do
    account
    uid { SecureRandom.uuid }
    account_uid { SecureRandom.hex }
  end
end
