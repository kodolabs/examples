FactoryGirl.define do
  factory :user do
    name      { FFaker::Name.first_name }
    surname   { FFaker::Name.last_name }
    email     { FFaker::Internet.email }
    phone     { FFaker::PhoneNumber.phone_number }

    password  'password'
    password_confirmation 'password'

    trait :organiser do
      after(:create) do |user|
        user.organiser ||= FactoryGirl.build(:organiser)
      end
    end
  end
end
