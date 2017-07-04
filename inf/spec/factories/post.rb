FactoryGirl.define do
  factory :post do
    author { FFaker::Name.name }
    title { FFaker::Lorem.sentence }
    content { FFaker::Lorem.sentence }
    description { FFaker::Lorem.phrase }
    uid { SecureRandom.uuid }
    posted_at Time.current
    likes_count 0
    shares_count 0
    comments_count 0
    page
    story { FFaker::Lorem.sentence }

    transient do
      owned_page false
    end

    trait :with_image do
      after(:create) do |p|
        p.images << create(:image)
      end
    end

    trait :with_video do
      after(:create) do |p|
        p.videos << create(:video)
      end
    end

    trait :shared do
      after(:create) do |post, evaluator|
        share = create(:share)
        post.shares << share
        create(:publication, share: share, owned_page: evaluator.owned_page)
      end
    end

    trait :with_twitter_opengraph do
      attrs do
        {
          'entities' => {
            'urls' => [
              { 'url' => 'http://esquire.com/news.html' }
            ]
          }
        }
      end
    end
  end
end
