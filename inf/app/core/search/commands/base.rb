module Search
  module Commands
    class Base
      def initialize(query, options = {})
        @query = query
        @max_id = options[:max_id]
        @page = options[:page]
        @result_type = options[:result_type]
        @trending = options[:trending] == 'true'
        @user = options[:user]
        @type = options[:type]
      end

      def call
        return [] if @query.blank?
        save_query
        decorate(items)
      end

      private

      def save_query
        return if @max_id.present? || @trending
        SearchQuery.create(term: @query.strip, user: @user)
      end

      def items
        news_items = ::Search::Commands::News.new(@query, options).call
        post_items.merge(news_items)
      end

      def post_items
        ::Search::Commands::Twitter.new(@query, options).call
      end

      def decorate(items)
        ::Search::Commands::Decorate.new(items, customer: @user.customer).call
      end

      def options
        {
          max_id: @max_id,
          result_type: @result_type,
          page: @page,
          type: @type
        }
      end
    end
  end
end
