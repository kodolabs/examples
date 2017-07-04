FactoryGirl.define do
  factory :rss_source do
    title { FFaker::Lorem.sentence }
    url { FFaker::Internet.http_url }

    trait :google do
      url { "https://www.google.com/alerts/#{SecureRandom.hex}" }
    end

    trait :with_topics do
      after(:create) do |s|
        2.times { s.topics << create(:topic) }
      end
    end

    trait :pubmed do
      url { "https://eutils.ncbi.nlm.nih.gov/#{SecureRandom.hex}" }
    end
  end
end
