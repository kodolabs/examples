FactoryGirl.define do
  factory :user do
    name  { FFaker::Name.first_name }
    email { FFaker::Internet.email }
    role  { :admin }

    password 'password'
    password_confirmation 'password'
  end
end
