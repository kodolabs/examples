require 'rails_helper'

describe Categories::FeaturedPages do
  let(:query) { Categories::FeaturedPages }
  let(:customer) { create(:customer, :with_feed, :with_profile, :with_topics) }
  let(:feed) { customer.primary_feed }

  let(:category) { create(:category, topics: customer.topics) }
  let(:featured_page) { create(:featured_page, categories: [category]) }
  let(:page) { create(:page) }
  let(:source_page) { create(:source_page, page: page, feed: feed) }
  let(:featured_page2) { create(:featured_page, categories: [category], page: page) }

  context 'success' do
    specify 'featured pages with categories' do
      featured_page
      res = query.new(feed).query
      expect(res.count).to eq(1)
      expect(res.keys).to eq [category.title]
      expect(res.values).to eq [[featured_page]]
    end

    specify 'featured pages, not in feed' do
      source_page
      featured_page2
      featured_page
      res = query.new(feed).query
      expect(res.count).to eq(1)
      expect(res.keys).to eq [category.title]
      expect(res.values).to eq [[featured_page]]
    end

    specify 'without feed' do
      featured_page
      res = query.new.query
      expect(res.count).to eq(1)
      expect(res.keys).to eq [category.title]
      expect(res.values).to eq [[featured_page]]
    end
  end
end
