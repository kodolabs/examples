FactoryGirl.define do
  factory :poll do
    question { FFaker::Lorem.word }
    multiple_choice { false }
    event
  end
end
