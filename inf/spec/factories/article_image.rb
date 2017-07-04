FactoryGirl.define do
  factory :article_image do
    file 'somepath.jpg'

    trait :real do
      file do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec', 'fixtures', 'images', 'customer_logo.jpg')
        )
      end
    end
  end
end
