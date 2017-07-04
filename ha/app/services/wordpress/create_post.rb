class Wordpress::CreatePost < Wordpress::ApiBase
  def call
    update_last_error
    raise I18n.t('notifications.invalid_password_or_login') unless access_to_wp?
    init_wrapper
    publish_to_wp
    update_article
  rescue => e
    update_last_error("WP publish: #{e.message}")
  end

  private

  def init_wrapper
    @wrapper ||= WP::API::Client.new(host: host.domain.name)
    @wrapper.basic_auth(username: host.wp_login, password: host.wp_password)
  end

  def publish_to_wp
    @post = wrapper.create_post({
      title: article.title,
      content: article_content,
      slug: article.slug,
      date: article.published_at&.to_datetime,
      status: :publish
    }.merge(post_categories).compact)
  end

  def update_article
    raise I18n.t('notifications.post_not_published_to_wp') if @post.blank?

    @article.update!(
      url: @post.link,
      external_id: @post.id,
      synced_at: Time.zone.now,
      publishing_status: :publish,
      status: :published
    )
  end
end
