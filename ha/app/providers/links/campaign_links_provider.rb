module Links
  class CampaignLinksProvider
    attr_accessor :h

    def initialize(links, h, domain_name)
      @links = links
      @h = h
      @domain_name = domain_name
    end

    def call
      collection = @links.map do |link|
        domain = link.blog.host.domain
        {
          client: @h.client_col(link.client),
          status_class: @h.domain_status_class(domain),
          status:  @h.domain_col(domain, :domain),
          anchor_path: @h.anchor_path_col(link, @domain_name),
          domain_links: domain.blog.links.count,
          blog_type: @h.blog_logo(domain.host.blog_type),
          domain_url: @h.domain_url(domain.name)
        }
      end
      collection.group_by { |link| link[:domain_url] }
        .map do |key, values|
        { url: key, links: values, status_class: values&.first.try(:[], :status_class) }
      end
    end
  end
end
