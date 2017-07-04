module Crawlers
  class SyncDown
    attr_accessor :blog, :domain

    def initialize(blog)
      @blog = blog
      @domain = blog.host.domain.decorate
    end

    def call
      update_last_error

      sync_blog_settings
      sync_posts
    rescue => e
      update_last_error("Crawlers sync down: #{e.message}")
    end

    private

    def update_last_error(message = nil)
      blog.host.update(last_error: message)
    end

    def sync_blog_settings
      info = Crawlers::SiteInfo.new(@domain).call
      return if info.blank?

      blog.host.update!(
        blog_title: info.name,
        description: info.description,
        author: info.author
      )
    end

    def sync_posts
      posts = Crawlers::Search.new(@domain).call
      posts.each do |post|
        service = Articles::AutoSave.call(blog: blog, post: post)
        raise service&.message if service.failure?
      end
    end
  end
end
