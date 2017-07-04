class Wordpress::ActivatePlugin < Wordpress::Base
  def call
    update_last_error
    raise I18n.t('notifications.invalid_password_or_login') unless access_to_wp?
    login_to_wp
    activate
    @host.update!(wp_auth_plugin: true)
    context.host = host
  rescue => e
    update_last_error("WP: #{e.message}")
    context.fail!(message: e.message)
  end

  private

  def login_to_wp
    login_form = agent.get("#{domain_url}/wp-login.php").form('loginform')
    login_form.log = host.wp_login
    login_form.pwd = host.wp_password
    agent.submit(login_form, login_form.buttons.first)
  end

  def domain_url
    domain = host.use_www? ? "www.#{@domain.name}" : @domain.name
    URI::HTTP.build(host: domain.gsub(/[[:space:]]/, '')).to_s
  end

  def activate
    page = @agent.get("#{domain_url}/wp-admin/plugins.php")
    if page.uri.to_s.index('wp-login.php').present?
      raise I18n.t('notifications.invalid_password_or_login')
    end

    return if page.at('a[aria-label="Deactivate JSON Basic Authentication"]').present?

    link = page.at('a[aria-label="Activate JSON Basic Authentication"]')
    raise I18n.t('notifications.no_plugin') if link.nil?

    Mechanize::Page::Link.new(link, agent, page).click
  end

  def agent
    @agent ||= Mechanize.new
  end

  def access_to_wp?
    [:wp_login, :wp_password].all? do |attr|
      host[attr].present?
    end
  end
end
