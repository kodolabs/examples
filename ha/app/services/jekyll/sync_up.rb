class Jekyll::SyncUp
  attr_accessor :blog, :host

  def initialize(blog, host)
    @blog = blog
    @host = host
  end

  def call
    return if blog.blank? || host.blank?
    update_last_error
    Jekyll::Publish.call(blog: blog, host: host)
    blog.update(synced_at: Time.zone.now)
  rescue => e
    update_last_error("Blog sync up: #{e.message}")
  end

  private

  def update_last_error(message = nil)
    host.update(last_error: message)
  end
end
