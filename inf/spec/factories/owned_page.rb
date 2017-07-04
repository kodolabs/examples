FactoryGirl.define do
  factory :owned_page do
    page
    account
    token { SecureRandom.uuid }
    last_updated_at { DateTime.now.utc }
  end
end
