require 'linkedin/service'
module Linkedin
  class SavePosts
    def initialize(page, options = {})
      @page = page
      @limit = options[:limit]
    end

    def call
      return if @page.blank?
      @page.touch(:last_crawled_at)
      @posts_count = 0

      return if token.blank?
      service = ::Linkedin::Posts.new(token)
      results = service.index(@page.uid)
      return if results.blank?
      decorated = ::Posts::Decorators::Linkedin.new(results).call
      return if decorated.blank?
      save(decorated)
    rescue ::Linkedin::AuthException, ::Linkedin::ApiException
      return
    end

    private

    def token
      @page.decorate.linkedin_api_token
    end

    def save(decorated)
      decorated.each do |attributes|
        return unless limit_not_reached?
        post = @page.posts.find_or_initialize_by(uid: attributes.uid)
        post.assign_attributes(attributes.to_h.except(:picture))
        post.save if post.changed?
        post.images.find_or_create_by(url: attributes.picture)
        @posts_count += 1 if post&.persisted?
        post
      end
    end

    def limit_not_reached?
      return true if @limit.blank?

      @posts_count < @limit
    end
  end
end
