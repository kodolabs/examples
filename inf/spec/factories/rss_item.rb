FactoryGirl.define do
  factory :rss_item do
    rss_source
    title { FFaker::Lorem.sentence }
    text { FFaker::Lorem.paragraph }
    author { FFaker::Name.name }
    image_url { FFaker::Internet.http_url }
    url { FFaker::Internet.http_url }
    published_at { FFaker::Time.datetime }
    external_id { FFaker::Internet.http_url }
    status :unread

    trait :without_image do
      image_url nil
    end
  end
end
