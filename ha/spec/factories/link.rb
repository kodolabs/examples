FactoryGirl.define do
  factory :link do
    article
    anchor_text { FFaker::Lorem.word }
    link_url { FFaker::Internet.http_url }
  end
end
