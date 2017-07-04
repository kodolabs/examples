require 'rails_helper'

RSpec.describe Customer, type: :model do
  let(:customer) { create :customer }

  context 'FactoryGirl :customer' do
    it 'work and valid' do
      expect(customer).to be_valid
      expect(create(:customer, :with_subscription)).to be_valid
      expect(create(:customer, :with_pro_subscription)).to be_valid
    end

    it 'create only one customer' do
      expect { create(:customer) }.to change { Customer.count }.from(0).to(1)
      expect { create(:customer, :with_subscription) }.to change { Customer.count }.by(1)
      expect { create(:customer, :with_pro_subscription) }.to change { Customer.count }.by(1)
    end
  end

  context 'Validations' do
    it { expect(subject).to validate_presence_of(:business_type_id) }
    it { expect(subject).to validate_presence_of(:business_name) }
  end

  context 'Scopes' do
    let(:customer_2) { create :customer }

    it '.ordered' do
      customer
      customer_2
      expect(Customer.ordered.to_a).to match_array [customer, customer_2]
    end
  end

  context 'Relationships' do
    it { expect(subject).to have_one(:subscription) }
    it { expect(subject).to have_one(:credit_card) }
    it { expect(subject).to have_one(:plan).through(:subscription) }

    it { expect(subject).to have_many(:users) }
    it { expect(subject).to have_many(:locations) }

    it { expect(subject).to have_many(:payments).through(:subscription) }
    it { expect(subject).to have_many(:reviews).through(:locations) }
    it { expect(subject).to have_many(:connections).through(:locations) }
    it { expect(subject).to have_many(:requests) }
    it { expect(subject).to have_many(:feedback_templates) }
    it { expect(subject).to have_many(:tasks) }
    it { expect(subject).to have_many(:alerts) }
    it { expect(subject).to have_many(:access_tokens) }

    it { expect(subject).to belong_to(:business_type) }
    it { expect(subject).to belong_to(:created_by) }
    it { expect(subject).to belong_to(:selected_plan) }
  end

  describe 'Callback' do
    it { expect(subject).to callback(:set_up_notify_date).before(:create) }
    it { expect(subject).to callback(:set_terms_accepted_at).before(:save) }
  end

  describe 'Methods' do
    describe '#primary_user' do
      it 'is first user' do
        expect(customer.primary_user).to eq customer.users.first
      end
    end

    describe '#primary_email' do
      it 'is first users email' do
        expect(customer.primary_email).to eq customer.users.first.email
      end
    end

    describe '#exists_payment_info?' do
      it 'false without braintree_card_token' do
        customer.braintree_card_token = nil
        expect(customer.payment_info?).to be_falsy
      end

      it 'true with braintree_card_token' do
        customer.braintree_card_token = 'test_token'
        expect(customer.payment_info?).to be_truthy
      end
    end

    describe '#users_collection' do
      it 'return all customers users' do
        user_1 = customer.primary_user
        expect(customer.users_collection).to match_array [
          ["#{user_1.first_name} #{user_1.last_name}", user_1.id]
        ]

        user_2 = create :user, customer: customer
        expect(customer.users_collection).to match_array [
          ["#{user_1.first_name} #{user_1.last_name}", user_1.id],
          ["#{user_2.first_name} #{user_2.last_name}", user_2.id]
        ]
      end
    end

    describe '#task_users_collection' do
      it 'for one user' do
        user_1 = customer.primary_user.decorate
        expect(customer.task_users_collection).to match_array [[user_1.safe_name, user_1.id]]
      end
    end
  end
end
