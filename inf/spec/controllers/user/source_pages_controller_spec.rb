require 'rails_helper'

describe User::SourcePagesController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }

  context 'search' do
    specify 'success' do
      sign_in(user)
      allow_any_instance_of(Search::Commands::SourcePages::Base).to receive(:call)
      get :search, params: { q: 123, provider: 'facebook' }
      expect(response.status).to eq 200
    end
  end
end
