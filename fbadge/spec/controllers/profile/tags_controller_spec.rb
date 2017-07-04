require 'rails_helper'

describe Profile::TagsController, type: :controller do
  let(:tag) { create(:tag) }

  def valid_params
    { tag: { keyword: FFaker::Lorem.word } }
  end

  def params(attrs = {})
    valid_params.deep_merge(tag: attrs)
  end

  context 'create tag' do
    specify 'success' do
      post :create, params: params, xhr: true
      valid_response = { id: Tag.last.id }.to_json
      expect(response.body).to eq(valid_response)
    end

    specify 'fail' do
      post :create, params: params(keyword: tag.keyword), xhr: true
      error_response = { errors: ['Keyword has already been taken'] }.to_json
      expect(response.body).to eq(error_response)
    end
  end
end
