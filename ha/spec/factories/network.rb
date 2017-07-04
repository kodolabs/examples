FactoryGirl.define do
  factory :network do
    title { "#{FFaker::Lorem.word} #{FFaker::Lorem.word}" }
    color { "##{FFaker::Color.hex_code}" }
  end
end
