require 'rails_helper'

describe TopicsController, type: :controller do
  let(:user) { create :user }
  let(:topic) { create :topic }

  before { sign_in user }

  def valid_params
    { topic: { keyword: FFaker::Lorem.word } }
  end

  def params(attrs = {})
    valid_params.deep_merge(topic: attrs)
  end

  context 'create topic via xhr' do
    specify 'success' do
      post :create, params: params, xhr: true
      valid_response = { id: Topic.last.id }.to_json
      expect(response.body).to eq(valid_response)
    end

    specify 'fail' do
      post :create, params: params(keyword: topic.keyword), xhr: true
      error_response = { errors: ['Keyword has already been taken'] }.to_json
      expect(response.body).to eq(error_response)
    end
  end
end
