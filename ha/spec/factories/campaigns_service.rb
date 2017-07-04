FactoryGirl.define do
  factory :campaigns_service do
    campaign

    trait :seo do
      service_type { :seo }
    end

    trait :ppc do
      service_type { :ppc }
    end

    trait :social do
      service_type { :social }
    end
  end
end
