FactoryGirl.define do
  factory :banned_keyword do
    keyword { SecureRandom.hex }
  end
end
