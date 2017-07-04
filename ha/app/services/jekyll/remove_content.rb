class Jekyll::RemoveContent
  attr_accessor :host

  def initialize(host)
    @host = host
  end

  def call
    return if host.blank?
    update_last_error
    Jekyll::PublishEmptyBlog.call(host: host, blog: host.blog)
  rescue => e
    update_last_error("Jekyll remove content: #{e.message}")
  end

  private

  def update_last_error(message = nil)
    host.update(last_error: message)
  end
end
