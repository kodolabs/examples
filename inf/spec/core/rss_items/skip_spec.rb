require 'rails_helper'

describe RssItems::Skip do
  let(:service) { RssItems::Skip }

  context 'skip rss item' do
    it 'success' do
      rss_item = create :rss_item, status: :unread
      expect(rss_item.unread?).to be_truthy
      service.call(rss_item)
      expect(rss_item.unread?).to be_falsey
      expect(rss_item.skipped?).to be_truthy
    end

    context 'invalid when' do
      it 'rss item saved' do
        rss_item = create :rss_item, status: :saved
        expect(rss_item.saved?).to be_truthy
        service.call(rss_item)
        expect(rss_item.skipped?).to be_falsey
      end
    end
  end
end
