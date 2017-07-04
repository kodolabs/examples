FactoryGirl.define do
  factory :proposal do
    transient do
      with_procedures { [create(:procedure)] }
    end

    start_date { Date.tomorrow }
    days_in_hospital 36

    after(:build) do |p, e|
      e.with_procedures.each do |procedure|
        p.proposal_procedures << build(:proposal_procedure, proposal: p, procedure: procedure)
      end
    end
  end
end
