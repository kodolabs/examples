module Shares
  module Decorators
    class Base
      include Rails.application.routes.url_helpers
      URI_REGEXP = %r{(?:f|ht)tps?:\/[^\s]+}

      def initialize(record, options = {})
        @record = record
        @quote = options[:quote]
      end

      def call
        data = decorate(@record)
        to_openstruct(data)
      end

      def max_content_size
        ::Articles::Validator::TWIITER_MAX_CONTENT_SIZE
      end

      def max_link_size
        ::Articles::Validator::TWITTER_MAX_LINK_SIZE
      end

      def to_openstruct(data)
        OpenStruct.new(data.compact)
      end

      def opengraph?(url)
        return false if url.blank? || social_url?(url)
        begin
          page = RestClient.get url
          service = ::OpenGraph::Base.new(page, url)
          service.call
          service.title.present?
        rescue
          nil
        end
      end

      def quote
        quote = ''
        quote += "#{@quote}\n\n" if @quote.present?
        quote
      end

      def cut(optional_text, required_text = '')
        text = optional_text + required_text
        urls_count = text.scan(/https*:/).count
        urls_length = urls_count * max_link_size
        max_content_length = max_content_size - urls_length - 3
        res = optional_text.truncate(max_content_length).to_s
        res += "\n\n#{required_text}" if required_text.present?
        res
      end

      def without_urls(text)
        text.split(URI_REGEXP).map do |s|
          s unless s =~ URI_REGEXP
        end.join
      end

      private

      def social_url?(url)
        url.include?('facebook.com') || url.include?('twitter.com')
      end
    end
  end
end
