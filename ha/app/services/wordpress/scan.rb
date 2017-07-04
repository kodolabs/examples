class Wordpress::Scan
  attr_accessor :host, :domain, :params

  def initialize(host)
    @host = host
    @domain = host.domain.decorate
    @params = {}
  end

  def call
    check_www
    update_host
  rescue => e
    @host.update(last_error: "Scan: #{e.message}")
  end

  private

  def check_www
    page = Mechanize.new.get(domain.domain_url)
    return if page&.uri.blank?
    @params[:use_www] = page.uri.host.index('www').present?
  end

  def update_host
    @host.update(@params)
  end

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError
    false
  end
end
