require 'rails_helper'

describe CustomersServices::Update do
  let(:customer) { create :customer, :with_subscription }
  let(:user) { customer.primary_user }

  describe '#call' do
    it 'update customer user' do
      params = { users_attributes: { '0' => { id: customer.primary_user.id, first_name: 'First1' } } }
      expect { CustomersServices::Update.new(customer, params).call }.to change { customer.primary_user.reload.first_name }.to('First1')
    end

    it 'update demo user to real and send invite' do
      customer.update(demo: true)
      params = { demo: false }
      expect { CustomersServices::Update.new(customer, params).call }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'update user email' do
      params = { business_name: 'New Business Name', users_attributes: { '0' => { id: user.id, first_name: 'First1', email: 'new_email@email.com' } } }
      expect { CustomersServices::Update.new(customer, params, nil, can_change_email: true).call }.to change { user.reload.email }.to('new_email@email.com')
    end

    it 'not update user email' do
      params = { business_name: 'New Business Name', users_attributes: { '0' => { id: user.id, first_name: 'First1', email: 'new_email@email.com' } } }
      expect { CustomersServices::Update.new(customer, params).call }.to_not change { user.reload.email }
    end
  end
end
