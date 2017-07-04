require 'rails_helper'

describe SourcePages::AddToFeed do
  let!(:user) { create :user }
  let!(:customer) { user.customer }
  let!(:feed) { customer.feeds.first }
  let!(:category) { create :category, title: 'Recommendations' }
  let!(:facebook_page) { create :page, :facebook }
  let!(:featured_page) { create :featured_page, page: facebook_page, categories: [category] }
  let!(:service) { SourcePages::AddToFeed }

  specify "shouldn't create source page if feed is wrong" do
    service.call(featured_page.id, 0)
    expect(SourcePage.count).to eq(0)
  end

  specify "shouldn't create source page if featured page is wrong" do
    service.call(0, feed.id)
    expect(SourcePage.count).to eq(0)
  end

  specify "shouldn't create source page if source already exist if feed" do
    create :source_page, feed: feed, page: facebook_page
    service.call(featured_page.id, feed.id)
    expect(SourcePage.count).to eq(1)
  end

  specify 'should create new source page' do
    service.call(featured_page.id, feed.id)
    expect(SourcePage.count).to eq(1)
  end
end
