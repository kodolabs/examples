FactoryGirl.define do
  factory :video do
    post
    url { FFaker::Internet.http_url }
    thumb_url { FFaker::Internet.http_url }
  end
end
