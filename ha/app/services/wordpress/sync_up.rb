class Wordpress::SyncUp
  attr_accessor :blog

  def initialize(blog)
    @blog = blog
  end

  def call
    return if blog.blank?
    update_last_error

    setup_auth_plugin
    sync_settings
    sync_posts
    remove_content
    finish_sync
  rescue => e
    update_last_error("Blog sync up: #{e.message}")
  end

  private

  def setup_auth_plugin
    return if blog.host.wp_auth_plugin
    service = Wordpress::Setup.call(host: blog.host)
    raise service&.message if service.failure?
  end

  def sync_settings
    Wordpress::UpdateSettings.new(blog.host).call
  end

  def sync_posts
    blog.articles.need_sync.each do |article|
      Wordpress::PublishPost.call(article: article)
    end
  end

  def remove_content
    Wordpress::RemoveContent.new(blog.host).call
  end

  def finish_sync
    blog.update(synced_at: Time.zone.now)
  end

  def update_last_error(message = nil)
    blog.host.update(last_error: message)
  end
end
