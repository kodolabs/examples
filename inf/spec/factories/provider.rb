FactoryGirl.define do
  factory :provider do
    name 'facebook'

    trait :facebook do
      name 'facebook'
    end

    trait :twitter do
      name 'twitter'
    end

    trait :google do
      name 'google'
    end

    trait :linkedin do
      name 'linkedin'
    end
  end

  preload do
    factory(:facebook)  { create :provider, :facebook }
    factory(:twitter)   { create :provider, :twitter }
    factory(:google) { create :provider, :google }
    factory(:linkedin) { create :provider, :linkedin }
  end
end
