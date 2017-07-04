module Crawlers
  class Presenter
    attr_accessor :url, :content

    def initialize(url, content)
      @url = url
      @content = content
    end

    def call
      OpenStruct.new(
        id: external_id,
        url: url,
        title: title,
        body: text,
        published_at: published,
        author: author,
        categories: categories,
        slug: slug
      )
    end

    private

    def doc
      @doc ||= Nokogiri::HTML(@content)
    end

    def url_path
      @path ||= URI.parse(@url)&.path&.gsub(%r{^/+|/+$}, '')
    end

    def external_id
      url_path
    end

    def slug
      return if url_path.blank?
      url_path.split('/').last
    end

    def title
      Crawlers::Settings.title_selectors.map do |selector|
        result = doc.at_css(selector)&.text&.strip
        return result if result.present?
      end.compact.first
    end

    def text
      content = Crawlers::Settings.text_selectors.map do |selector|
        result = doc.at_css(selector)&.to_html
        return result if result.present?
      end.compact.first
      content.presence || doc.at('body').children.to_html
    end

    def categories
      Crawlers::Settings.category_selectors.map do |selector|
        nodes = doc.css(selector)
        return nodes.map { |node| node&.text&.strip } if nodes.present?
      end.compact
    end

    def published
      date = Crawlers::Settings.date_selectors.map do |selector|
        result = if selector.is_a?(Array)
          doc.at_css(selector.first).try(:[], selector.second)
        else
          doc.at_css(selector)&.text&.strip
        end
        result = Time.zone.parse(result) rescue nil if result.present?
        return result if result.present?
      end.compact.first
      date ||= Time.zone.parse(url_path) rescue nil
      date
    end

    def author
      Crawlers::Settings.author_selectors.map do |selector|
        result = doc.at_css(selector)&.text&.strip
        return result if result.present?
      end.compact.first
    end
  end
end
