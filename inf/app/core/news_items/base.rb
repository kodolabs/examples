module NewsItems
  class Base < Rectify::Command
    def initialize(form)
      @form = form
    end

    def domain_for(news)
      return if news.url.blank?
      host = Addressable::URI.parse(news.url).host.split('www.').last rescue nil
      return nil if host.blank?
      news.rss_domain = RssDomain.find_by(host: host)
    end
  end
end
