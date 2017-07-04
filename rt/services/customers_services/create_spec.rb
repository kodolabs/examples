require 'rails_helper'

describe CustomersServices::Create do
  let(:customer) { create :customer }

  describe '#call' do
    it 'create new customer and user without password' do
      expect(Customer.count).to eq 0
      expect(User.count).to eq 0
      expect(Subscription.count).to eq 0

      params = {
        created_by: nil,
        selected_plan_id: plans(:plan_basic).id,
        business_type_id: BusinessType.first.id,
        business_name: 'Some Name',
        business_phone: '1415421324',
        users_attributes: {
          '0' => { email: 'example@example.com', first_name: 'first', last_name: 'last', phone: '1321321231' }
        }
      }
      customer = CustomersServices::Create.new(params).call

      expect(customer.persisted?).to be_truthy
      expect(Customer.count).to eq 1
      expect(User.count).to eq 1
      expect(Subscription.count).to eq 0
      expect(customer).to_not be_nil
      expect(customer.selected_plan).to_not be_nil
      expect(customer.business_name).to eq 'Some Name'
      expect(customer.primary_user).to_not be_nil
      expect(customer.primary_user.email).to eq 'example@example.com'
      expect(customer.primary_user.first_name).to eq 'first'
      expect(customer.primary_user.last_name).to eq 'last'
      expect(customer.primary_user.phone).to eq '1321321231'
    end

    it 'create new customer with subscription' do
      expect(Customer.count).to eq 0
      expect(User.count).to eq 0
      expect(Subscription.count).to eq 0

      params = {
        created_by: nil,
        business_type_id: BusinessType.first.id,
        business_name: 'Some Name',
        business_phone: '1415421324',
        users_attributes: { '0' => { email: 'example@example.com', first_name: 'some', last_name: 'another', phone: 'dasdasd' } },
        selected_plan_id: plans(:plan_basic).id
      }

      customer = CustomersServices::Create.new(params).call

      expect(customer.persisted?).to be_truthy
      expect(customer.selected_plan).to_not be_nil
      expect(customer.business_name).to eq 'Some Name'
      expect(Customer.count).to eq 1
      expect(User.count).to eq 1
      expect(Subscription.count).to eq 0
    end

    it 'return false for user with duplicated email' do
      params = { created_by: nil, users_attributes: { '0' => { email: customer.primary_email } } }
      customer = CustomersServices::Create.new(params).call
      expect(customer.persisted?).to be_falsy
    end
  end
end
