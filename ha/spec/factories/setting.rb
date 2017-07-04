FactoryGirl.define do
  factory :setting do
    var { FFaker::Lorem.word }
    value { FFaker::Lorem.word }
  end
end
