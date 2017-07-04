require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:location) { create :location }

  context 'FactoryGirl :location' do
    it { expect(location).to be_valid }
  end

  context 'Validations' do
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to validate_presence_of(:address) }
    it { expect(subject).to validate_presence_of(:city) }
    it { expect(subject).to validate_presence_of(:postcode) }
    it { expect(subject).to validate_presence_of(:country) }
    it { expect(subject).to validate_presence_of(:state) }
    it 'location with flagging rule' do
      subject.flagging = true
      expect(subject).to validate_presence_of(:flagging_rule)
    end
    it 'location with flagging rule' do
      subject.flagging = false
      expect(subject).to_not validate_presence_of(:flagging_rule)
    end
  end

  context 'Relationships' do
    it { expect(subject).to belong_to(:customer) }
    it { expect(subject).to belong_to(:manager) }
    it { expect(subject).to have_many(:reviews) }
    it { expect(subject).to have_many(:connections) }
    it { expect(subject).to have_many(:sources) }
    it { expect(subject).to have_and_belong_to_many(:users) }
    it { expect(subject).to have_and_belong_to_many(:location_groups) }
    it { expect(subject).to have_and_belong_to_many(:alerts) }
  end
end
