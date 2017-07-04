class Wordpress::UpdatePost < Wordpress::ApiBase
  def call
    update_last_error
    raise I18n.t('notifications.post_not_published_to_wp') if article.external_id.blank?
    raise I18n.t('notifications.invalid_password_or_login') unless access_to_wp?
    init_wrapper
    publish_to_wp
    update_article
  rescue => e
    update_last_error("WP update: #{e.message}")
  end

  private

  def publish_to_wp
    @post = wrapper.update_post(
      article.external_id,
      {
        title: article.title,
        content: article_content,
        slug: article.slug,
        date: article.published_at&.to_datetime,
        status: article.publishing_status
      }.merge(post_categories).compact
    )
  end

  def update_article
    raise I18n.t('notifications.post_not_lublished_to_wp') if @post.blank?

    @article.update!(
      url: @post.link,
      synced_at: Time.zone.now
    )
  end
end
