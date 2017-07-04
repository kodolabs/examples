require 'rails_helper'

describe Admin::TopicsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:topic) { create(:topic) }

  before { sign_in(admin) }

  def valid_params
    { topic: { keyword: FFaker::Lorem.word.downcase } }
  end

  def params(attrs = {})
    valid_params.deep_merge(topic: attrs)
  end

  context 'create topic' do
    specify 'success' do
      expect { post :create, params: params }.to change(Topic, :count).by(1)
      expect(response.status).to eq(200)
    end
  end

  context 'create topic via xhr' do
    specify 'success' do
      post :create, params: params, xhr: true
      expect(response.status).to eq(200)
    end

    specify 'fail' do
      post :create, params: params(keyword: topic.keyword), xhr: true
      error_response = { errors: ['Keyword has already been taken'] }.to_json
      expect(response.body).to eq(error_response)
    end
  end
end
