FactoryGirl.define do
  factory :topic do
    keyword { SecureRandom.hex }
  end
end
