FactoryGirl.define do
  factory :account do
    provider
    login { FFaker::Lorem.word }
    password { FFaker::Lorem.word }
  end
end
