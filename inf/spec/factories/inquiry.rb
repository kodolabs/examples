FactoryGirl.define do
  factory :inquiry do
    username { FFaker::Name.first_name }
    email { FFaker::Internet.email }
    phone { FFaker::PhoneNumberAU.international_mobile_phone_number }
  end
end
