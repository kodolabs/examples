require 'rails_helper'

describe PreopForm do
  it { should belong_to(:patient) }
  it { should validate_presence_of(:patient) }

  describe '#data' do
    it 'should allow access by symbol' do
      expect(create(:preop_form).data[:height]).to eq '185'
    end
  end

  describe 'after created' do
    let!(:patient) { create(:patient) }
    let!(:demand) { create(:demand, patient: patient) }

    it 'should mark all preop enquiries as pending' do
      expect(demand.enquiries.first.pending?).to eq false
      create(:preop_form, patient: patient)
      expect(demand.enquiries.first.pending?).to eq true
    end
  end
end
