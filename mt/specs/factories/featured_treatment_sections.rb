FactoryGirl.define do
  factory :featured_treatment_section do
    title 'section 1'
    body { FFaker::Lorem.words }
    image 0
  end
end
