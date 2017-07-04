require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:customer).primary_user }

  describe 'FactoryGirl' do
    it 'work and valid' do
      expect(user).to be_valid
    end
  end

  context 'Relationships' do
    it { expect(subject).to belong_to(:customer) }
    it { expect(subject).to have_many(:alerts) }
    it { expect(subject).to have_many(:comments) }
    it { expect(subject).to have_many(:assigned_tasks) }
    it { expect(subject).to have_many(:created_tasks) }
    it { expect(subject).to have_many(:access_tokens) }
  end
end
