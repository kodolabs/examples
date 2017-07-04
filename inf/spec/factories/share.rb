FactoryGirl.define do
  factory :share do
    customer
    job_id { SecureRandom.uuid }

    trait :scheduled do
      scheduled_at { Time.zone.now + 1.day }
    end

    trait :expired do
      scheduled_at { Time.zone.now - 1.day }
    end

    shareable_type 'Article'

    trait :post do
      shareable_type 'Post'
    end

    trait :demo do
      customer { create(:customer, :demo) }
    end

    trait :linkedin do
      after(:create) do |s|
        account = create(:account, :linkedin, :with_linkedin_page, customer: s.customer)
        create(:publication, share: s, owned_page: account.owned_pages.first)
      end
    end

    trait :facebook do
      after(:create) do |s|
        account = create(:account, :facebook, :with_random_facebook_pages)
        create(:publication, share: s, owned_page: account.owned_pages.first)
      end
    end
  end
end
