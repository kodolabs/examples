require 'rails_helper'

describe RssItems::Save do
  let(:service) { RssItems::Save }

  context 'save rss item' do
    let(:topics) { create_list :topic, 3 }
    it 'success' do
      rss_source = create :rss_source, kind: :research
      rss_item = create :rss_item, status: :unread, image_url: nil, rss_source: rss_source
      topics = create_list :topic, 3
      expect(rss_item.saved?).to be_falsey
      service.call(rss_item, topics: topics.map(&:id))
      expect(rss_item.saved?).to be_truthy
      news = News.last
      expect(news.title).to eq(rss_item.title)
      expect(news.description).to eq(rss_item.text)
      expect(news.url).to eq(rss_item.url)
      expect(news.topics.size).to eq(topics.size)
      expect(news.kind).to eq('research')
    end

    context 'invalid when' do
      it 'empty list of topics' do
        rss_item = create :rss_item, status: :unread
        expect(rss_item.saved?).to be_falsey
        service.call(rss_item, {})
        expect(rss_item.saved?).to be_falsey
      end
    end

    context 'filtered' do
      let(:keyword) { create(:banned_keyword, keyword: 'Abra') }
      specify 'title' do
        keyword
        rss_item = create :rss_item, status: :unread, image_url: nil, title: 'Abra'
        expect_any_instance_of(NewsItems::Filter).to receive(:call).once.and_return(true)
        service.call(rss_item, topics: topics.map(&:id))
        expect(rss_item.saved?).to be_truthy
        expect(News.count).to eq(0)
      end
    end

    context 'duplicates' do
      let(:topics) { create_list :topic, 3 }
      let(:news) { create :news, url: 'http://kodolabs.com' }

      specify 'dont create news' do
        news
        rss_item = create :rss_item, :without_image, url: 'http://kodolabs.com'
        service.call(rss_item, topics: topics.map(&:id))
        expect(rss_item.saved?).to be_truthy
        expect(News.count).to eq(1)
      end

      specify 'create news' do
        news
        rss_item = create :rss_item, :without_image, url: 'http://kodo.com'
        service.call(rss_item, topics: topics.map(&:id))
        expect(rss_item.saved?).to be_truthy
        expect(News.count).to eq(2)
      end
    end

    context 'rss domains' do
      let(:rss_domain) { create(:rss_domain, :with_image, title: 'mail.com') }
      specify 'success' do
        rss_domain
        rss_source = create :rss_source, kind: :research
        rss_item = create :rss_item,
          status: :unread,
          image_url: nil,
          rss_source: rss_source,
          url: 'http://mail.com/new1.html'
        topics = create_list :topic, 3
        service.call(rss_item, topics: topics.map(&:id))
        news = News.last
        expect(news.title).to eq(rss_item.title)
        expect(news.rss_domain).to eq(rss_domain)
        expect(news.decorate.poster_url).to include(rss_domain.image.url)
      end
    end
  end
end
