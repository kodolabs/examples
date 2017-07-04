FactoryGirl.define do
  factory :article do
    blog
    title { FFaker::Lorem.word }
    body { FFaker::LoremFR.paragraph }
    published_at { Time.zone.now - 5.days }
    url { FFaker::Internet.http_url }
  end
end
