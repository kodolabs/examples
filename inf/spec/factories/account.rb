FactoryGirl.define do
  factory :account do
    customer
    uid { SecureRandom.uuid }
    token { SecureRandom.hex }
    expires_at { Time.zone.now + 1.hour }
    provider
    name { FFaker::Name.name }
    username { FFaker::InternetSE.login_user_name }
    secret { SecureRandom.hex }
    active true

    trait :twitter do
      provider { providers :twitter }
      secret { ENV['TWITTER_ACCOUNT_SECRET'] }
      token { ENV['TWITTER_ACCOUNT_TOKEN'] }
    end

    trait :facebook do
      provider { providers :facebook }
      token { ENV['FACEBOOK_ACCOUNT_TOKEN'] }
    end

    trait :google do
      provider { providers :google }
    end

    trait :linkedin do
      provider { providers :linkedin }
    end

    trait :with_facebook_page do
      after(:create) do |p|
        page = create(:page, :facebook, uid: ENV['FACEBOOK_PAGE_UID'], handle: 'Mikelangelo')
        p.pages << page
        p.owned_pages.where(account_id: p.id).update(token: ENV['FACEBOOK_PAGE_TOKEN'])
      end
    end

    trait :with_random_facebook_pages do
      after(:create) do |p|
        2.times do
          page = create(:page, :facebook)
          p.pages << page
        end
      end
    end

    trait :with_twitter_page do
      after(:create) do |p|
        page = create(:page, :twitter)
        p.pages << page
      end
    end

    trait :with_linkedin_page do
      after(:create) do |p|
        page = create(:page, :linkedin)
        p.pages << page
      end
    end

    trait :with_facebook_posts do
      after(:create) do |p|
        p.pages.last.posts << create(:post)
      end
    end

    trait :with_twitter_posts do
      after(:create) do |p|
        p.pages.last.posts << create(:post)
      end
    end

    trait :demographics do
      after(:create) do |p|
        page = create(:page, :facebook, :demographics)
        p.pages << page
        p.owned_pages.where(account_id: p.id).update(token: ENV['FACEBOOK_DEMOGRAPHICS_PAGE_TOKEN'])
      end
    end

    trait :with_old_crawled_fb_page do
      after(:create) do |a|
        page = create(:page, :facebook, :old_crawled, uid: SecureRandom.hex(10), handle: 'Mik')
        a.pages << page
      end
    end

    trait :with_analytics_config do
      after(:create) do |p|
        create(:analytics_config, account: p)
      end
    end

    trait :with_invalid_token do
      active false
    end

    trait :nearly_notified do
      after(:create) do |p|
        customer = create(:customer, :nearly_notified)
        customer.accounts << p
      end
    end

    trait :old_notified do
      after(:create) do |p|
        customer = create(:customer, :old_notified)
        customer.accounts << p
      end
    end

    trait :expired do
      expires_at { Time.zone.now - 1.day }
    end
  end
end
