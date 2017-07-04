class Wordpress::UpdateSettings < Wordpress::ApiBase
  def initialize(host)
    @host = host
  end

  def call
    update_last_error
    raise I18n.t('notifications.invalid_password_or_login') unless access_to_wp?
    init_wrapper
    update_settings
    update_author
  rescue => e
    update_last_error("WP update settings: #{e.message}")
  end

  private

  def init_wrapper
    @wrapper ||= WP::API::Client.new(host: host.domain.name)
    @wrapper.basic_auth(username: host.wp_login, password: host.wp_password)
  end

  def update_settings
    params = {}
    params[:title] = host.blog_title if host.blog_title.present?
    params[:description] = host.description if host.description.present?

    @wrapper.update_settings(params) if params.present?
  end

  def update_author
    return if host.author.blank?

    user = @wrapper.users(search: host.wp_login, should_raise_on_empty: false)&.first
    @wrapper.update_user(user.id, name: host.author) if user.present?
  end
end
