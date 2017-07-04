FactoryGirl.define do
  factory :campaign do
    name { "Campaign #{SecureRandom.hex(5)}" }
    starts_at { Time.current + 1.week }
    duration 7
    interests '[{"id":"6003709831116","name":"Berry"}]'
    location '[
      {"key":"ME","name":"Montenegro","type":"country","country_name":"Montenegro"},
      {"key":"3869","name":"Montana","type":"region","country_name":"United States"},
      {"key":"294960","name":"Montreal","type":"city","country_name":"Canada","region":"Quebec"},
      {"key":"PL:65-083","name":"65-083","type":"zip","country_name":"Poland","region":"Lubusz Voivodeship"}
    ]'
    budget '150'
    fb_ad_account_id { SecureRandom.hex }

    trait :with_fb_ids do
      fb_campaign_id { SecureRandom.hex }
      fb_adset_id { SecureRandom.hex }
      fb_creative_id { SecureRandom.hex }
      fb_ad_id { SecureRandom.hex }
    end
  end
end
