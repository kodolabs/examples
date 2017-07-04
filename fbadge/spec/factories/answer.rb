FactoryGirl.define do
  factory :answer do
    position { 1 }
    value { FFaker::Lorem.word }
    poll
  end
end
