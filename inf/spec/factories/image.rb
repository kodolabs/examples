FactoryGirl.define do
  factory :image do
    post
    url { FFaker::Internet.http_url }
  end
end
