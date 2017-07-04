class Wordpress::RemoveContent
  attr_accessor :host, :blog, :wrapper

  def initialize(host)
    @host = host
    @blog = host.blog
    @post_ids = []
  end

  def call
    return if host.blank? || !host&.wordpress?
    update_last_error

    init_wrapper
    load_posts_from_wp
    remove_posts
    return_to_draft
  rescue => e
    update_last_error("WP remove content: #{e.message}")
  end

  private

  def init_wrapper
    @wrapper ||= WP::API::Client.new(host: host.domain.name)
    @wrapper.basic_auth(username: host.wp_login, password: host.wp_password)
  end

  def load_posts_from_wp
    page = 1
    loop do
      posts = find_posts(page)
      break if posts.blank?
      @post_ids.concat(posts.map(&:id))

      page += 1
    end
    @post_ids.uniq!
  end

  def remove_posts
    (@post_ids - article_external_ids).each do |post_id|
      delete_post(post_id)
    end
  end

  def return_to_draft
    ids = article_external_ids - @post_ids
    return if ids.blank?

    blog.articles
      .need_publish
      .where(external_id: ids)
      .update_all(
        url: nil,
        synced_at: nil,
        external_id: nil,
        publishing_status: :draft
      )
  end

  def article_external_ids
    @ids ||= blog.articles.need_publish.map do |a|
      a.external_id.to_i if a.external_id.present?
    end.compact
  end

  def find_posts(page)
    wrapper.posts(page: page, should_raise_on_empty: false)
  end

  def delete_post(id)
    wrapper.delete_post(id, should_raise_on_empty: false)
  end

  def update_last_error(message = nil)
    host.update(last_error: message)
  end
end
