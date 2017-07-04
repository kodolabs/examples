FactoryGirl.define do
  factory :provider do
    provider_type { :host }
    name { FFaker::Name.name }
    url { FFaker::Internet.domain_name }
  end
end
