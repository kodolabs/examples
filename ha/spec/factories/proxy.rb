FactoryGirl.define do
  factory :proxy do
    address { FFaker::Lorem.word }
    port { FFaker::Lorem.word }
    is_https 'Yes'
    login { FFaker::Lorem.word }
    password { FFaker::Lorem.word }
  end
end
