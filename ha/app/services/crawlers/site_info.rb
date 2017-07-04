module Crawlers
  class SiteInfo
    attr_accessor :domain, :doc

    def initialize(domain)
      @domain = domain
    end

    def call
      page = agent.get(domain.domain_url)
      parse_info(page)
    end

    private

    def agent
      @agent ||= Mechanize.new
    end

    def parse_info(page)
      @doc ||= Nokogiri::HTML(page.content)

      OpenStruct.new(
        name: search_title,
        description: search_description,
        author: search_author
      )
    end

    def search_title
      [
        'title',
        ['meta[name="title"]', %w(content value)],
        ['meta[name="site_name"]', %w(content value)],
        ['meta[property="site_name"]', %w(content value)],
        ['meta[property="og:site_name"]', %w(content value)],
        ['meta[property="title"]', %w(content value)],
        ['meta[property="og:title"]', %w(content value)]
      ].map do |selector|
        result = search_value_by_selector(selector)
        return result if result.present?
      end.compact.first
    end

    def search_description
      [
        ['meta[name="description"]', %w(content value)],
        ['meta[property="description"]', %w(content value)],
        ['meta[property="og:description"]', %w(content value)]
      ].map do |selector|
        result = search_value_by_selector(selector)
        return result if result.present?
      end.compact.first
    end

    def search_author
      [
        ['meta[name="author"]', %w(content value)],
        ['meta[property="author"]', %w(content value)],
        ['meta[property="og:author"]', %w(content value)]
      ].map do |selector|
        result = search_value_by_selector(selector)
        return result if result.present?
      end.compact.first
    end

    def search_value_by_selector(selector)
      element = if selector.is_a?(Array)
        doc.at_css(selector.first)
      else
        doc.at_css(selector)
      end

      return if element.blank?
      return element&.text&.strip unless selector.is_a?(Array)

      selector.second.map do |attribute|
        element.try(:[], attribute)
      end.compact.first
    end
  end
end
