require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:task) { create :task }

  describe 'FactoryGirl' do
    it 'work and valid' do
      expect(task).to be_valid
    end
  end

  describe 'Relations' do
    it { expect(subject).to belong_to(:customer) }
    it { expect(subject).to belong_to(:review) }
    it { expect(subject).to belong_to(:assigned_to) }
    it { expect(subject).to belong_to(:created_by) }
    it { expect(subject).to have_many(:comments) }
  end

  describe 'Validations' do
    it { expect(subject).to validate_presence_of(:title) }
    it { expect(subject).to validate_presence_of(:task_type) }
    it { expect(subject).to validate_presence_of(:status) }
    it { expect(subject).to validate_presence_of(:customer_id) }
    it { expect(subject).to validate_presence_of(:created_by_id) }
  end
end
