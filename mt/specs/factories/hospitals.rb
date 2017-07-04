FactoryGirl.define do
  factory :hospital do
    name { FFaker::Lorem.word }
    description { FFaker::Lorem.word }
    plus_partner false
    visible true
    location { create_locations_ancestry('Eastern Europe', 'Poland', 'Warsaw').last }
    latitude 1.1
    longitude 1.1
  end
end
