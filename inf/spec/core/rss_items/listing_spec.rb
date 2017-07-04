require 'rails_helper'
describe RssItems::Listing do
  let!(:news_rss_source) { create(:rss_source, kind: :news) }
  let!(:research_rss_source) { create(:rss_source, kind: :research) }
  let!(:rss_item_1) { create(:rss_item, rss_source: news_rss_source) }
  let!(:rss_item_2) { create(:rss_item, rss_source: research_rss_source) }
  let!(:rss_item_3) { create(:rss_item, rss_source: news_rss_source) }

  context 'Without kind' do
    let(:query_result) { RssItems::Listing.new(nil).query }
    it 'returns rss items from both sources' do
      ids = query_result.to_a.map(&:id)
      expect(ids.size).to eq(3)
      expect(ids).to contain_exactly(rss_item_1.id, rss_item_2.id, rss_item_3.id)
    end
  end

  context 'With research kind' do
    let(:query_result) { RssItems::Listing.new(:research).query }

    it 'returns rss items from research source' do
      ids = query_result.to_a.map(&:id)
      expect(ids.size).to eq(1)
      expect(ids).to contain_exactly(rss_item_2.id)
    end
  end

  context 'With news kind' do
    let(:query_result) { RssItems::Listing.new(:news).query }

    it 'returns rss items from research source' do
      ids = query_result.to_a.map(&:id)
      expect(ids.size).to eq(2)
      expect(ids).to contain_exactly(rss_item_1.id, rss_item_3.id)
    end
  end
end
