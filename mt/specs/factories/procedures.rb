FactoryGirl.define do
  factory :procedure do
    name { FFaker::Lorem.word }
  end
end
