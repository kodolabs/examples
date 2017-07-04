FactoryGirl.define do
  factory :host_account do
    account
    login { FFaker::Lorem.word }
    password { FFaker::Lorem.word }
  end
end
