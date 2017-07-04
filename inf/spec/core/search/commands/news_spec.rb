require 'rails_helper'

describe Search::Commands::News do
  let(:service) { Search::Commands::News }

  context 'success' do
    specify 'any page' do
      news = create(:news, title: 'google')
      res = service.new('Google').call
      valid_response = { last_page: true, news: [news] }
      expect(res).to eq valid_response
    end

    specify 'only news' do
      news = create(:news, title: 'google')
      allow(News).to receive(:detailed_search).and_return(News.all)
      expect(News).to receive(:detailed_search).once
      res = service.new('Google', type: 'news').call
      valid_response = { last_page: true, news: [news] }
      expect(res).to eq valid_response
    end
  end

  context 'fail' do
    let(:blank) { { last_page: true, news: [] } }
    specify 'empty query' do
      expect(News).not_to receive(:detailed_search)
      res = service.new(nil).call
      expect(res).to eq(blank)
    end

    specify 'twitter pagination' do
      expect(News).not_to receive(:detailed_search)
      res = service.new('some', type: 'trends').call
      expect(res).to eq(blank)
    end
  end
end
