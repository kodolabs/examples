require 'rails_helper'

describe CustomersServices::StatusUpdate do
  let(:customer) { create :customer }

  describe 'cancel account' do
    it 'set customer as canceled' do
      CustomersServices::StatusUpdate.new(customer, 'cancelled').call
      expect(customer.status).to eq 'cancelled'
      expect(customer.canceled_at.to_date).to eq DateTime.now.to_date
      expect(customer.errors.empty?).to be_truthy
    end

    it 'return error for already cancelled customer' do
      customer.status = 'cancelled'
      customer.canceled_at = 1.day.ago
      CustomersServices::StatusUpdate.new(customer, 'cancelled').call
      expect(customer.status).to eq 'cancelled'
      expect(customer.canceled_at.to_date).to eq 1.day.ago.to_date
      expect(customer.errors.empty?).to be_falsy
    end
  end

  describe 'suspend account' do
    it 'suspend customer account' do
      expect(Harvester).to receive(:pause).and_return(true)
      CustomersServices::StatusUpdate.new(customer, 'suspended').call
      expect(customer.status).to eq 'suspended'
      expect(customer.suspended_at.to_date).to eq DateTime.now.to_date
      expect(customer.errors.empty?).to be_truthy
    end

    it 'for already suspended customer account' do
      customer.status = 'suspended'
      customer.suspended_at = 1.day.ago
      CustomersServices::StatusUpdate.new(customer, 'suspended').call
      expect(customer.status).to eq 'suspended'
      expect(customer.suspended_at.to_date).to eq 1.day.ago.to_date
      expect(customer.errors.empty?).to be_falsy
    end
  end

  describe 'activate account' do
    it 'activate suspended customer account' do
      customer.status = 'suspended'
      customer.suspended_at = 1.day.ago
      expect(Harvester).to receive(:resume).and_return(true)
      CustomersServices::StatusUpdate.new(customer, 'active').call
      expect(customer.status).to eq 'active'
      expect(customer.suspended_at).to be_nil
      expect(customer.errors.empty?).to be_truthy
    end
  end

  describe 'try to set invalid status' do
    it 'return error' do
      CustomersServices::StatusUpdate.new(customer, 'invalid_status').call
      expect(customer.errors.empty?).to be_falsy
      expect(customer.errors.full_messages).to include 'Invalid status'
    end
  end
end
