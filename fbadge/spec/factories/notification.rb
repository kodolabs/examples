FactoryGirl.define do
  factory :notification do
    title { FFaker::Lorem.word }
    text { FFaker::Lorem.word }
  end
end
