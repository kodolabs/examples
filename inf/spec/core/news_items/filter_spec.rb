require 'rails_helper'

describe NewsItems::Filter do
  let(:service) { NewsItems::Filter }
  let(:keyword) { create(:banned_keyword, keyword: 'awesome') }
  let(:rss_item) { create(:rss_item, title: 'awesome aa') }

  context 'rss' do
    context 'success' do
      specify 'camel-sensitive' do
        keyword
        rss_item
        expect(service.new(rss_item).call).to be_truthy
      end
    end
  end
end
