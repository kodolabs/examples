require 'rails_helper'

describe User::SearchesController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }

  context 'show' do
    specify 'success' do
      sign_in(user)
      allow_any_instance_of(Search::TrendingSearches).to receive(:query).and_return([])
      expect_any_instance_of(Search::TrendingSearches).to receive(:query).once
      get :show
      expect(response.status).to eq 200
    end
  end

  context 'fetch' do
    specify 'success' do
      sign_in(user)
      res = { posts: [], max_id: 1 }
      allow_any_instance_of(Search::Commands::Base).to receive(:call).and_return(res)
      expect_any_instance_of(Search::Commands::Base).to receive(:call).once
      p = {
        q: 'Twitter post',
        max_id: 'last_twitter_post_uid',
        result_type: 'best'
      }
      get :fetch, params: p
    end
  end
end
