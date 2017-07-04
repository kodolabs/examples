FactoryGirl.define do
  factory :card do
    customer
    name { FFaker::NameMX.full_name }
    address { FFaker::AddressAU.street_address }
    city { FFaker::AddressAU.city }
    postcode { FFaker::AddressAU.postcode }
    country 'UA'
    brand 'Visa'
    last4 '4242'
  end
end
