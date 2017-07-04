FactoryGirl.define do
  factory :source_page do
    title FFaker::Lorem.sentence
    feed
    page
  end
end
