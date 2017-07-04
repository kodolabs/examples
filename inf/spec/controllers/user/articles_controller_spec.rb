require 'rails_helper'

describe User::ArticlesController, type: :controller do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  let(:scheduled_service) { Articles::ScheduledPosts }
  let(:account) { create(:account, :facebook, :with_facebook_page, customer: customer) }

  context 'fetch' do
    specify 'success' do
      sign_in(user)
      allow_any_instance_of(Articles::Fetch).to receive(:call)
      allow_any_instance_of(Articles::Fetch).to receive(:data).and_return(true)
      expect_any_instance_of(Articles::Fetch).to receive(:call).once
      get :fetch, params: { a: '123' }
      expect(response.status).to eq 200
    end

    specify 'fail' do
      sign_in(user)
      allow_any_instance_of(Articles::Fetch).to receive(:call)
      allow_any_instance_of(Articles::Fetch).to receive(:data).and_return(false)
      expect_any_instance_of(Articles::Fetch).to receive(:call).once
      get :fetch
      expect(response.status).to eq 400
    end
  end

  context 'index' do
    specify 'xhr' do
      account
      sign_in(user)
      articles = [create(:article)]
      allow_any_instance_of(scheduled_service).to receive(:query).and_return(articles)
      expect_any_instance_of(scheduled_service).to receive(:query).once

      get :index, params: {}, xhr: true
      expect(response.status).to eq(200)
      json_articles = JSON.parse(articles.to_json)
      expect(JSON.parse(response.body)['articles']).to eq(json_articles)
    end

    specify 'success' do
      account
      sign_in(user)
      articles = [create(:article)]
      allow_any_instance_of(scheduled_service).to receive(:query).and_return(articles)
      expect_any_instance_of(scheduled_service).to receive(:query).once

      get :index, params: {}
      expect(response.status).to eq(200)
    end
  end

  context 'destroy' do
    let(:worker) { DestroyShareWorker }
    specify 'success' do
      create(:account, :facebook, :with_facebook_page, customer: customer)
      share = create(:share, customer: customer)

      sign_in(user)
      allow(worker).to receive(:perform_async)
      expect(worker).to receive(:perform_async).once

      delete :destroy, params: { id: share.id }
      expect(response.status).to eq(200)
      expect(flash.first).to include 'Post will be deleted shortly'
    end
  end
end
