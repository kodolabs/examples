FactoryGirl.define do
  factory :user do
    customer
    email { FFaker::Internet.email }
    password 'password'
    password_confirmation 'password'
    confirmed_at { Time.current - 1.day }
    confirmation_token { SecureRandom.uuid }
  end
end
