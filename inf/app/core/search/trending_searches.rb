module Search
  class TrendingSearches < Rectify::Query
    def query
      cache.fetch('trending_searches', expires_in: 1.hour) do
        top_terms
      end
    end

    private

    def cache
      @cache ||= ActiveSupport::Cache::RedisStore.new
    end

    def top_terms
      SearchQuery
        .where('created_at >= ?', 1.week.ago)
        .group(:term)
        .select('term, count(*) as cnt')
        .order('cnt DESC')
        .limit(5)
        .map(&:term)
    end
  end
end
