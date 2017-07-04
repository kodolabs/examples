require 'rails_helper'

describe Admin::NewsController, type: :controller do
  let(:admin) { create(:admin) }

  context 'update posts' do
    specify 'success' do
      sign_in(admin)
      valid_data = { title: 'Esquire' }
      allow_any_instance_of(NewsItems::Fetch).to receive(:call)
      allow_any_instance_of(NewsItems::Fetch).to receive(:data).and_return(valid_data)
      expect_any_instance_of(NewsItems::Fetch).to receive(:call).once
      expect_any_instance_of(NewsItems::Fetch).to receive(:data).once

      get :fetch, params: { url: 'http://esquire.com' }
      expect(response.body).to eq(valid_data.to_json)
    end
  end

  context 'blacklist posts' do
    let(:service) { NewsItems::Blacklist }
    specify 'success' do
      sign_in(admin)
      allow_any_instance_of(service).to receive(:call)
      expect_any_instance_of(service).to receive(:call).once

      post :blacklist, params: { q: 'abc' }
      expect(response).to redirect_to(admin_news_index_path)
    end
  end
end
