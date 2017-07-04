FactoryGirl.define do
  factory :article do
    content { FFaker::Lorem.sentence }
    customer

    transient do
      owned_pages false
      scheduled_at false
      job_id false
    end

    after(:create) do |article, evaluator|
      if evaluator.owned_pages
        share = create(:share, shareable: article)
        share.owned_pages = evaluator.owned_pages
        share.scheduled_at = evaluator.scheduled_at if evaluator.scheduled_at
        share.job_id = evaluator.job_id if evaluator.job_id
        share.customer = article.customer
        share.save
      end
    end

    trait :with_image do
      after(:create) do |article|
        article.images << create(:article_image, :real)
      end
    end
  end
end
