module Crawlers
  class Search
    attr_accessor :domain
    ALLOWED_EXTENSION = %w(
      php htm html
    ).freeze

    INVALID_PATHS = [
      '',
      'xmlrpc',
      'wp-login',
      'tags',
      'archives',
      'contact',
      'about',
      'comments',
      'categories',
      'wp-json/.+',
      '.+/feed/',
      'category/[\w\-]+',
      'author/[\w\-]+'
    ].freeze

    def initialize(domain)
      @domain = domain
      @articles = []
      @used_paths = []
    end

    def call
      Spider.start_at(domain.domain_url) do |s|
        s.add_url_check do |a_url|
          next if a_url.index(domain.name).blank?
          next if a_url.start_with?('/') && a_url.size > 1

          uri = URI.parse(a_url)
          next if uri&.host&.index(domain.name).blank?
          next if uri&.path&.index('index.').present?

          extension = File.extname(uri&.path)
          extension.slice!(0)
          extension.blank? || ALLOWED_EXTENSION.include?(extension)
        end

        s.on :success do |a_url, resp, _prior_url|
          path = URI.parse(a_url)&.path&.downcase

          next if skip_path?(path)

          add_article_to_collection(a_url, resp.body)
          @used_paths << path
        end
      end
      @articles
    end

    private

    def add_article_to_collection(url, content)
      @articles << Crawlers::Presenter.new(url, content).call
    end

    def skip_path?(path)
      return true if @used_paths.include?(path)
      return true if (path =~ %r{^/[0-9]{4}/[0-9]{1,2}/?$}).present?
      return true if path.blank? || INVALID_PATHS.map do |invalid_path|
                       (path =~ %r{^/#{invalid_path}(.[a-z]{1,4})?/?$}).present?
                     end.any?
      false
    end
  end
end
