require 'rails_helper'

RSpec.describe RssItem::CreateOrUpdate do
  let!(:rss_source) { create :rss_source, kind: :research }
  let(:rss_source2) { create(:rss_source, :google) }
  let(:rss_source3) { create(:rss_source, :pubmed) }

  context 'success' do
    def create_item(custom = {})
      OpenStruct.new(
        custom.reverse_merge(
          summary: 'Some text',
          title: 'Some title',
          author: 'Some author',
          image: FFaker::Internet.http_url,
          published: Time.zone.now,
          entry_id: SecureRandom.hex,
          url: FFaker::Internet.http_url
        )
      )
    end

    before(:each) do
      allow_any_instance_of(RssItem::CreateOrUpdate).to receive(:search_site_info).and_return({})
      allow_any_instance_of(RssItem::CreateOrUpdate).to receive(:find_image_in_opengraph).and_return(nil)
    end

    specify 'without entry_id' do
      expect_any_instance_of(RssItem::CreateOrUpdate).to receive(:item_image_valid?).and_return(true)

      url = 'https://esquire.com'
      item = create_item(url: url, entry_id: nil)
      result = RssItem::CreateOrUpdate.new(rss_source, item).call
      expect(result).to be_truthy
      expect(RssItem.count).to eq(1)
      expect(RssItem.last.external_id).to eq(url)
    end

    specify 'create new item' do
      expect(RssItem.count).to eq(0)
      expect_any_instance_of(RssItem::CreateOrUpdate).to receive(:item_image_valid?).and_return(true)

      url = 'https://esquire.com'
      item = create_item(url: url)
      result = RssItem::CreateOrUpdate.new(rss_source, item).call
      expect(result).to be_truthy

      rss_item = RssItem.last

      expect(RssItem.count).to eq(1)
      expect(rss_item.text).to eq(item.summary)
      expect(rss_item.title).to eq(item.title)
      expect(rss_item.image_url).to eq(item.image)
      expect(rss_item.external_id).to eq(item.entry_id)
      expect(rss_item.unread?).to be_truthy
      expect(rss_item.url).to eq(item.url)
    end

    specify 'create google alerts item' do
      expect(RssItem.count).to eq(0)
      expect_any_instance_of(RssItem::CreateOrUpdate).to receive(:item_image_valid?).and_return(true)

      url = 'http://www.immortal.org/abc'
      item = create_item(url: "https://www.google.com/url?rct=j&sa=t&url=#{url}&usg=A")
      result = RssItem::CreateOrUpdate.new(rss_source2, item).call
      expect(result).to be_truthy

      rss_item = RssItem.last

      expect(RssItem.count).to eq(1)
      expect(rss_item.text).to eq(item.summary)
      expect(rss_item.title).to eq(item.title)
      expect(rss_item.image_url).to eq(item.image)
      expect(rss_item.external_id).to eq(item.entry_id)
      expect(rss_item.unread?).to be_truthy
      expect(rss_item.url).to eq(url)
    end

    specify 'create new item and create news' do
      rss_source.update(add_automatically: true)
      rss_source.topics.create(keyword: 'test')

      expect_any_instance_of(RssItem::CreateOrUpdate).to receive(:item_image_valid?).and_return(true)

      item = create_item(image: nil)
      result = RssItem::CreateOrUpdate.new(rss_source, item).call
      expect(result).to be_truthy

      rss_item = RssItem.last

      expect(RssItem.count).to eq(1)
      expect(rss_item.text).to eq(item.summary)
      expect(rss_item.title).to eq(item.title)
      expect(rss_item.image_url).to eq(item.image)
      expect(rss_item.external_id).to eq(item.entry_id)
      expect(rss_item.read?).to be_truthy

      expect(News.count).to eq(1)

      news_item = News.last
      expect(rss_item.text).to eq(news_item.description)
      expect(rss_item.title).to eq(news_item.title)
      expect(news_item.kind).to eq('research')
    end

    specify 'update exist item' do
      rss_item = create :rss_item, rss_source: rss_source, status: :unread
      expect_any_instance_of(RssItem::CreateOrUpdate).to receive(:item_image_valid?).and_return(true)

      item = create_item(entry_id: rss_item.external_id)
      result = RssItem::CreateOrUpdate.new(rss_source, item).call
      expect(result).to be_truthy

      rss_item.reload

      expect(RssItem.count).to eq(1)
      expect(rss_item.text).to eq(item.summary)
      expect(rss_item.title).to eq(item.title)
      expect(rss_item.image_url).to eq(item.image)
      expect(rss_item.external_id).to eq(item.entry_id)
      expect(rss_item.unread?).to be_truthy
    end

    specify 'skipped item should be not updated' do
      rss_item = create :rss_item, rss_source: rss_source, status: :skipped

      item = create_item(entry_id: rss_item.external_id)
      result = RssItem::CreateOrUpdate.new(rss_source, item).call
      expect(result).to be_falsey

      rss_item.reload

      expect(RssItem.count).to eq(1)
      expect(rss_item.text).to_not eq(item.summary)
      expect(rss_item.title).to_not eq(item.title)
      expect(rss_item.image_url).to_not eq(item.image)
      expect(rss_item.external_id).to eq(item.entry_id)
      expect(rss_item.skipped?).to be_truthy
    end

    specify 'saved item should be not updated' do
      rss_item = create :rss_item, rss_source: rss_source, status: :saved

      item = create_item(entry_id: rss_item.external_id)
      result = RssItem::CreateOrUpdate.new(rss_source, item).call
      expect(result).to be_falsey

      rss_item.reload

      expect(RssItem.count).to eq(1)
      expect(rss_item.text).to_not eq(item.summary)
      expect(rss_item.title).to_not eq(item.title)
      expect(rss_item.image_url).to_not eq(item.image)
      expect(rss_item.external_id).to eq(item.entry_id)
      expect(rss_item.saved?).to be_truthy
    end

    specify 'create pubmed item' do
      expect(RssItem.count).to eq(0)
      expect_any_instance_of(RssItem::CreateOrUpdate).to receive(:item_image_valid?).and_return(true)

      item = create_item(
        summary: "<p>Zhang W</p><p>Abstract<br/> BACKGROUND:
          Obstructive <a href='http://medical.com'>Awesome</a></p>",
        url: 'http://med.com'
      )
      result = RssItem::CreateOrUpdate.new(rss_source3, item).call
      expect(result).to be_truthy

      rss_item = RssItem.last

      expect(RssItem.count).to eq(1)
      expect(rss_item.text).to include 'Obstructive'
      expect(rss_item.url).to eq('http://medical.com')
    end
  end
end
