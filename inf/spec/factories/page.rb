FactoryGirl.define do
  factory :page do
    provider
    handle { FFaker::Name.name }
    uid { SecureRandom.uuid }
    handle_type 'handle'
    last_crawled_at { DateTime.now.utc }
    last_updated_at { DateTime.now.utc }
    logo 'https://scontent.xx.fbcdn.net/v/t1.0-1/c15.0.50.50/p50x50/399548_10149999285987789_1102888142_n.png?oh=bdf22659929b60d2530a472381162098&oe=590DF16A'

    trait :twitter do
      provider { providers(:twitter) }
    end

    trait :facebook do
      provider { providers(:facebook) }
    end

    trait :linkedin do
      provider { providers(:linkedin) }
    end

    trait :hashtag do
      handle_type 'hashtag'
    end

    trait :test do
      uid ENV['FACEBOOK_PAGE_UID']
      handle 'Mikelangelo'
    end

    trait :demographics do
      handle 'influenzamsm'
      uid nil
    end

    trait :old_crawled do
      last_updated_at { 2.days.ago }
    end

    trait :with_linkedin_account do
      after(:create) do |p|
        account = create(:account, :linkedin)
        token = SecureRandom.uuid
        p.owned_pages.create(account: account, token: token)
      end
    end
  end
end
