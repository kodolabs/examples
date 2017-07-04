module Links
  class DomainLinksProvider
    attr_accessor :h

    def initialize(links, h)
      @links = links
      @h = h
    end

    def call
      collection = @links.map do |link|
        domain = link.blog.host.domain
        {
          client: @h.client_col(link.client),
          status_class: @h.domain_status_class(domain),
          status:  @h.campaign_col(link),
          anchor_path: @h.domain_anchor_col(link),
          domain_links: domain.blog.links.count,
          blog_type: @h.blog_logo(domain.host.blog_type),
          domain_url: @h.domain_url(domain.name)
        }
      end
      collection.sort_by { |item| item[:client] }
        .group_by { |link| link[:status] }
        .map { |key, values| { url: key, links: values } }
    end
  end
end
