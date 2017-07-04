module OpenGraph
  class Base
    def initialize(page, url)
      @page = page
      @url = url
    end

    def call
      @doc = doc_for(@page)
    end

    def title
      parse_tag(:title)
    end

    def site_name
      parse_tag(:site_name) || parse_html_tag('meta[name=application-name]')
    end

    def title_from_url
      uri = URI.parse(@url)
      uri.host&.gsub('www.', '')
    end

    def image
      uri = parse_tag :image
      escape(uri)
    end

    def description
      parse_tag :description
    end

    def favicon
      OpenGraph::Favicon.new(@doc, @url).call
    end

    private

    def parse_tag(title, options = {})
      prefix = options[:prefix] || 'og'
      property_selector = "meta[property='#{prefix}:#{title}']"
      name_selector = "meta[name='#{prefix}:#{title}']"

      tag = @doc.at_css(property_selector) || @doc.at_css(name_selector)

      value_for(tag)
    end

    def parse_html_tag(title)
      tag = @doc.at_css(title)
      value_for(tag)
    end

    def value_for(tag)
      tag.try(:attributes).try(:[], 'content').try(:value)
    end

    def doc_for(page)
      @page_html ||= page.is_a?(Nokogiri::HTML::Document) ? page : Nokogiri::HTML.parse(page)
    end

    protected

    def escape(url)
      return nil if url.blank?
      CGI.unescapeHTML(url) rescue nil
    end
  end
end
