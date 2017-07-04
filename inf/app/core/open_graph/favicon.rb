module OpenGraph
  class Favicon < ::OpenGraph::Base
    def initialize(doc, url)
      @doc = doc
      @url = url
    end

    def call
      search(@doc, @url)
    end

    private

    def search(doc, url)
      icon = high_quality_icon(doc, url)
      return icon if icon.present?
      low_quality_icon(doc, url)
    end

    def high_quality_icon(doc, url)
      tags = doc.xpath('//link[@href][contains(@rel, "icon")]')
      icons = {}

      tags.map do |tag|
        size = tag[:sizes].to_i
        icons[size] = tag[:href]
      end

      best_icon = icons[icons.keys.max]
      prepare_url(url, best_icon)
    end

    def low_quality_icon(doc, url)
      icon = doc.xpath('//link[@href][contains(@rel, "shortcut")]').first
      prepare_url(url, icon)
    end

    def prepare_url(url, favicon)
      return nil if favicon.blank?
      favicon = escape(favicon)
      return "http:#{favicon}" if another_domain?(favicon)
      return favicon if absolute_url?(favicon)
      custom_url(favicon, url)
    rescue
      nil
    end

    def another_domain?(favicon_url)
      return false if favicon_url.blank?
      favicon_url.start_with?('//')
    rescue
      return false
    end

    def absolute_url?(favicon_url)
      return false if favicon_url.blank?
      favicon_url&.index('http').present? && URI.parse(favicon_url).host.present?
    rescue
      false
    end

    def custom_url(favicon_url, url)
      return nil if favicon_url.blank?
      path, query = "/#{favicon_url&.strip&.gsub(%r{^(\.+/?\.+)?/}, '')}".split('?')
      URI::HTTP.build(
        host: URI.parse(url).host,
        path: path,
        query: query
      ).to_s
    rescue
      nil
    end
  end
end
