require 'rails_helper'

describe User::FollowedPagesController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  let(:account) { create(:account, :facebook, customer: customer) }

  context 'success' do
    let(:fb_service) { FollowedPages::Facebook }
    let(:form) { FollowedPages::Form }
    specify 'new' do
      allow_any_instance_of(fb_service).to receive(:call).and_return(['a'])
      expect_any_instance_of(fb_service).to receive(:call).once
      sign_in(user)
      get :new, params: { id: account.id }
      expect(assigns(:form).pages).to eq(['a'])
      expect(assigns(:form).account).to eq(account)
      expect(response.status).to eq(200)
    end

    specify 'no pages' do
      allow_any_instance_of(fb_service).to receive(:call).and_return([])
      expect_any_instance_of(fb_service).to receive(:call).once
      sign_in(user)
      get :new, params: { id: account.id }
      expect(response.status).to eq(400)
    end
  end
end
