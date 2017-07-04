FactoryGirl.define do
  factory :verification do
    customer
    identity do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'images', 'customer_logo.jpg')
      )
    end
    address do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'images', 'customer_logo.jpg')
      )
    end

    trait :approved do
      status :approved
    end

    trait :declined do
      status :declined
    end
  end
end
