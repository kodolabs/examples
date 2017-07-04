FactoryGirl.define do
  factory :receptionist do
    name      { FFaker::Name.first_name }
    email     { FFaker::Internet.email }
    token     { FFaker::Lorem.word }
  end
end
