FactoryGirl.define do
  factory :publication do
    owned_page
    share
    uid { SecureRandom.uuid }
  end
end
