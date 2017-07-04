module Search
  module Commands
    class News
      LIMIT = 10

      def initialize(query, options = {})
        @query = query
        @page = options[:page].presence ? options[:page].to_i : 1
        @type = options[:type]
      end

      def call
        return blank if @query.blank? || no_news_query?
        res = search(@query).page(@page).per(LIMIT)
        {
          last_page: res.last_page?,
          news: res
        }
      end

      def search(query)
        ::News.detailed_search(query.strip)
      end

      def no_news_query?
        @type.presence && @type != 'news'
      end

      def blank
        { last_page: true, news: [] }
      end
    end
  end
end
