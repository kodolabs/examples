class Wordpress::Detect
  attr_accessor :domain

  def initialize(domain_name)
    @domain = domain_name
  end

  def call
    detect
  rescue Mechanize::ResponseCodeError
    false
  rescue
    false
  end

  private

  def detect
    page = Mechanize.new.get(url)
    uri = URI.parse(page.uri.to_s) rescue nil
    uri&.path == url.path
  end

  def url
    URI::HTTP.build(host: domain, path: '/wp-login.php')
  end
end
