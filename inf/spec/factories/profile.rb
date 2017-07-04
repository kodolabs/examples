FactoryGirl.define do
  factory :profile do
    user
    profession
    time_zone 'Kyiv'
    full_name { FFaker::Name.name }
    data do
      {
        date_of_birth: FFaker::Time.between(30.years.ago, 20.years.ago).strftime('%d/%m/%Y'),
        country: FFaker::AddressAU.country,
        languages: [FFaker::Locale.language]
      }.to_json
    end

    phone { FFaker::PhoneNumberAU.international_mobile_phone_number }

    trait :before_spread do
      after :create do |profile, evaluator|
        return if evaluator.data.blank?
        # transient doesn't works here
        current_data = {
          full_name: FFaker::Name.name,
          date_of_birth: FFaker::Time.between(30.years.ago, 20.years.ago).strftime('%d/%m/%Y'),
          contact_number: FFaker::PhoneNumberAU.international_mobile_phone_number,
          languages: [FFaker::Locale.language],
          time_zone: 'Midway Island',
          country: FFaker::AddressAU.country,
          workplaces: [create(:workplace, title: 'before_spread').id],
          friends: ['before_spread@mail.com']
        }

        updated_data = current_data.merge(evaluator.data)
        profile.data = updated_data.to_json
        profile.save
      end
    end
  end
end
