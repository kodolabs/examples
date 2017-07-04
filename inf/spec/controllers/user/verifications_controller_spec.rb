require 'rails_helper'

describe User::VerificationsController, type: :controller do
  context 'success' do
    let(:customer) { create(:customer, :with_profile) }
    let(:user) { customer.primary_user }

    specify 'new' do
      user
      sign_in(user)
      get :new
      expect(response.status).to eq(200)
    end
  end

  context 'fail' do
    let(:customer1) { create(:customer, :with_user) }
    let(:user1) { customer1.primary_user }

    let(:customer2) { create(:customer, :with_active_subscr) }
    let(:user2) { customer2.primary_user }

    specify 'verified' do
      user2
      sign_in(user2)
      get :new
      expect(response.status).to eq(302)
      expect(response).to redirect_to user_accounts_path
    end
  end
end
