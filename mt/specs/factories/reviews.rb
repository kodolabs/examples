FactoryGirl.define do
  factory :review do
    quality_rating 40
    services_rating 50
    overall_rating 60
    overall_description { FFaker::Lorem.words(10) }
  end
end
