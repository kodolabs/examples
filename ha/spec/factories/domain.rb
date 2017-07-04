FactoryGirl.define do
  factory :domain do
    network
    status { :active }
    name { FFaker::Internet.domain_name }

    after(:create) do |domain|
      Monitorings::Enum.types.keys.each do |type|
        create :monitoring, domain: domain, monitoring_type: type
      end
    end
  end
end
