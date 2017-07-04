FactoryGirl.define do
  factory :tag do
    keyword { SecureRandom.hex }
  end
end
