FactoryGirl.define do
  factory :demand do
    transient do
      hospitals { [create(:hospital)] }
    end

    purpose :booking
    patient
    procedures { [create(:procedure)] }
    description { FFaker::Lorem.word }
    date_from Date.today
    date_to Date.tomorrow

    after(:create) do |demand, evaluator|
      evaluator.hospitals.each do |hospital|
        demand.enquiries << create(:enquiry, demand: demand, hospital: hospital)
      end
    end
  end
end
