FactoryGirl.define do
  factory :workplace do
    title { SecureRandom.hex }
  end
end
