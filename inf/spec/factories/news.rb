FactoryGirl.define do
  factory :news do
    title { FFaker::Book.title }
    url { FFaker::Internet.http_url }
    description { FFaker::Lorem.sentence }
    source_title { FFaker::Lorem.sentence }

    transient do
      with_topic false
      owned_page false
    end

    trait :with_image do
      image do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec', 'fixtures', 'images', 'customer_logo.jpg')
        )
      end
    end

    after(:create) do |news, evaluator|
      news.topics << evaluator.with_topic if evaluator.with_topic
    end

    trait :shared do
      after(:create) do |news, evaluator|
        share = create(:share)
        news.shares << share
        create(:publication, share: share, owned_page: evaluator.owned_page)
      end
    end
  end
end
