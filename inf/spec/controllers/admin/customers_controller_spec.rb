require 'rails_helper'

describe Admin::CustomersController, type: :controller do
  let(:admin) { create(:admin) }

  context 'search' do
    before { sign_in(admin) }

    context 'phone number' do
      let(:customer) { create(:customer, :with_user) }
      let(:profile) { create(:profile, user: customer.primary_user, phone: '+61 4 7819 2350') }

      specify 'full number' do
        get :index, params: { q: profile.phone }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'without country code' do
        profile
        get :index, params: { q: '4 7819 2350' }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'with formatted phone' do
        profile
        get :index, params: { q: '+61 478 192 350' }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'without plus' do
        get :index, params: { q: profile.phone.delete('+') }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'without spaces' do
        get :index, params: { q: profile.phone.delete(' ') }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'with hyphen' do
        profile
        get :index, params: { q: '7819-2350' }
        expect(assigns(:customers)).to eq [customer]
      end
    end

    context 'full_name' do
      let(:customer) { create(:customer, :with_user) }
      let(:profile) { create(:profile, user: customer.primary_user, full_name: 'Coca Cola') }

      let(:customer2) { create(:customer, :with_user) }
      let(:profile2) { create(:profile, user: customer2.primary_user, full_name: 'Awesome2') }

      specify 'full word' do
        profile
        profile2
        get :index, params: { q: profile.full_name }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'part of word' do
        profile
        profile2
        get :index, params: { q: 'cola' }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'downcased' do
        profile
        profile2
        get :index, params: { q: 'coca cola' }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'with numbers' do
        profile
        profile2
        get :index, params: { q: profile2.full_name }
        expect(assigns(:customers)).to eq [customer2]
      end
    end

    context 'contact email' do
      let(:customer) { create(:customer) }
      let(:user) { create(:user, email: 'email@test.com', customer: customer) }
      let(:profile1) { create(:profile, user: user) }

      let(:customer2) { create(:customer) }
      let(:user2) { create(:user, email: 'fake2@test.com', customer: customer2) }
      let(:profile2) { create(:profile, user: user2) }

      specify 'full word' do
        profile1
        get :index, params: { q: user.email }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'part of word' do
        profile1
        get :index, params: { q: 'test.com' }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'upcased' do
        profile1
        get :index, params: { q: 'EmAil@test.com' }
        expect(assigns(:customers)).to eq [customer]
      end

      specify 'with numbers' do
        profile2
        get :index, params: { q: 'fake2' }
        expect(assigns(:customers)).to eq [customer2]
      end
    end
  end
end
