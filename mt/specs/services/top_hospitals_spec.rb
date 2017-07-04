require 'rails_helper'

describe TopHospitals do
  let(:user)       { create :user }
  let!(:patient)   { create :patient, user: user }
  let!(:procedure) { create :procedure }
  let!(:demand)    { create :demand, patient: patient, procedures: [procedure], multiple_hospitals: true }

  it 'should not return proposals if 2 hours gone and 3 proposals made' do
    3.times do
      enquiry = create :enquiry, :proposed, demand: demand
      create :proposal, with_procedures: [procedure], enquiry: enquiry
    end
    Timecop.travel(Time.now + 2.hours)
    expect(TopHospitals.new(demand).select).to be_empty
  end

  it 'should return top 5 proposals if 4 hours gone and 6 proposals made' do
    Timecop.travel(Time.now + 1.hour) do
      3.times do
        enquiry = create :enquiry, :proposed, demand: demand
        create :proposal, with_procedures: [procedure], enquiry: enquiry
      end
    end
    Timecop.travel(Time.now + 2.hours) do
      3.times do
        enquiry = create :enquiry, :proposed, demand: demand
        create :proposal, with_procedures: [procedure], enquiry: enquiry
      end
    end
    Timecop.travel(Time.now + 4.hours)
    expect(TopHospitals.new(demand).select.count).to eq(5)
  end

  it 'should not return proposals after proposals made and time has not passed' do
    3.times do
      enquiry = create :enquiry, :proposed, demand: demand
      create :proposal, with_procedures: [procedure], enquiry: enquiry
    end
    Timecop.travel(Time.now + 2.5.hours) do
      2.times do
        enquiry = create :enquiry, :proposed, demand: demand
        create :proposal, with_procedures: [procedure], enquiry: enquiry
      end
    end
    Timecop.travel(Time.now + 3.hours) do
      expect(TopHospitals.new(demand).select).to be_empty
    end
    Timecop.travel(Time.now + 4.hours) do
      expect(TopHospitals.new(demand).select.count).to eq(5)
    end
  end

  it 'should return all proposals if 12 hours gone' do
    Timecop.travel(Time.now + 3.hours) do
      3.times do
        enquiry = create :enquiry, :proposed, demand: demand
        create :proposal, with_procedures: [procedure], enquiry: enquiry
      end
    end
    Timecop.travel(Time.now + 5.hours) do
      3.times do
        enquiry = create :enquiry, :proposed, demand: demand
        create :proposal, with_procedures: [procedure], enquiry: enquiry
      end
    end
    Timecop.travel(Time.now + 12.hours)
    expect(TopHospitals.new(demand).select.count).to eq(5)
  end
end
