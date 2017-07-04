module SourcePages
  class AddToFeed < Rectify::Command
    def initialize(featured_page_id, feed_id)
      @featured_page_id = featured_page_id
      @feed_id = feed_id
    end

    def call
      feed = find_feed(@feed_id)
      return broadcast(:invalid_feed) unless feed
      featured_page = find_featured_page(@featured_page_id)
      return broadcast(:invalid_featured_page) unless featured_page
      return broadcast(:source_page_present) if feed.pages.include?(featured_page.page)
      source_page = new_source_page(feed, featured_page)
      return broadcast(:invalid_source_page) unless source_page.save
      broadcast(:ok, source_page)
    end

    private

    def find_feed(feed_id)
      Feed.find_by(id: feed_id)
    end

    def find_featured_page(featured_page_id)
      FeaturedPage.find_by(id: featured_page_id)
    end

    def new_source_page(feed, featured_page)
      feed.source_pages.create(title: featured_page.title, feed: feed, page: featured_page.page)
    end
  end
end
