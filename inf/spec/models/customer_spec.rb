require 'rails_helper'

describe Customer do
  context 'unverified' do
    context 'success' do
      specify 'without verification' do
        customer = build(:customer)
        expect(customer.unverified?).to be_truthy
      end

      specify 'declined' do
        customer = build(:customer, :declined)
        expect(customer.unverified?).to be_truthy
      end
    end
    context 'fail' do
      specify 'with verification' do
        customer = create(:customer, :with_active_subscr)
        expect(customer.unverified?).to be_falsey
      end
    end
  end

  context 'search' do
    specify 'phone' do
      customer = create(:customer, :with_user)
      create(:profile, user: customer.primary_user, phone: '+352661234562')
      expect(Customer.joins(users: :profile).search('562')).to eq [customer]
    end

    specify 'business name' do
      customer = create(:customer, :with_user)
      create(:profile, user: customer.primary_user, full_name: 'Nam')
      expect(Customer.joins(users: :profile).search('Nam')).to eq [customer]
    end
  end

  context 'demo' do
    specify 'generate token' do
      customer = create(:customer, :demo)
      customer.generate_demo_token
      expect(customer.demo_token).to be_truthy
      customer.demo = false
      customer.save
      customer.generate_demo_token
      expect(customer.demo_token).to be_falsey
    end
  end
end
