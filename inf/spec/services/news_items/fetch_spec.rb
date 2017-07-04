require 'rails_helper'

describe NewsItems::Fetch do
  let(:service) { NewsItems::Fetch.new('http://esquire.com') }
  let(:og_service) { OpenGraph::Base }

  context 'success' do
    specify 'fetch opengraph data' do
      allow(RestClient).to receive(:get)

      valid_data = {
        title: 'Esquire',
        site_title: 'Esqire site title',
        description: 'Top news',
        image: 'image.png?a=1',
        favicon: 'favicon.ico'
      }

      expect_any_instance_of(og_service).to receive(:call).once
      allow_any_instance_of(og_service).to receive(:title) { valid_data[:title] }
      allow_any_instance_of(og_service).to receive(:description) { valid_data[:description] }
      allow_any_instance_of(og_service).to receive(:favicon) { valid_data[:favicon] }
      allow_any_instance_of(og_service).to receive(:site_name) { valid_data[:site_title] }
      allow_any_instance_of(og_service).to receive(:image) { 'image.png?a=1' }

      service.call
      expect(service.data).to eq(valid_data)
    end
  end
end
