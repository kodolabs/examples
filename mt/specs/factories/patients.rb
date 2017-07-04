FactoryGirl.define do
  factory :patient do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    address 'address'
    city { FFaker::AddressUA.city }
    country 'ua'
    # email { FFaker::Internet.email }
    phone { FFaker::PhoneNumber.phone_number }
    religion 'religion'
    diet 'diet'
  end
end
