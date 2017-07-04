FactoryGirl.define do
  factory :rss_domain do
    title { 'http://mail.com' }
    host { 'mail.com' }
    trait :with_image do
      image do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec', 'fixtures', 'images', 'customer_logo.jpg')
        )
      end
    end
  end
end
