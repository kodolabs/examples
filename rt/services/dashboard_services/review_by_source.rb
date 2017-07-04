module DashboardServices
  module ReviewBySource
    SHOW_COUNT = 5

    def sources_by_count
      @sources_by_count ||= source_query.order('sources.count DESC')
    end

    def reviews_by_source
      @reviews_by_source ||= top_reviews_by_source.each_with_index { |obj, index| obj[:color] ||= Analysis::COLORS[index % Analysis::COLORS.length] }
    end

    def reviews_by_source_by_chart
      reviews_by_source.map { |obj| obj.merge y: obj[:percent] }
    end

    def reviews_by_all_sources
      @reviews_by_all_source ||= begin
        res_total = Review.where(source_id: sources_by_count.map(&:id)).group(:source_id).pluck('source_id, COUNT(1)')
        sources_by_count.map do |s|
          percent = (s.count.to_f / reviews_count * 100).round
          total_reviews = res_total.find { |i| i[0] == s.id }.dig(1)
          { id: s.id, name: s.name, value: s.count, avg: s.avg, percent: percent, total_reviews: total_reviews }
        end
      end
    end

    def top_reviews_by_source
      res = reviews_by_all_sources.to_a
      return res if res.size <= Analysis::SOURCE_PIE_TOP_COUNT
      top = res.slice!(0, Analysis::SOURCE_PIE_TOP_COUNT)
      others = res.each_with_object(name: I18n.t('customer.dashboard.charts.reviews_by_sources.sources.other'), value: 0, total_rating: 0, total: 0, total_reviews: 0, id: nil) do |s, sum|
        sum[:value] += s[:value]
        sum[:total_reviews] += s[:total_reviews]
        if s[:avg]
          sum[:total_rating] += s[:value] * s[:avg]
          sum[:total] += s[:value]
        end
        sum
      end
      if others.present? && others[:value].to_i.positive?
        others[:avg] = (others[:total_rating] / others[:total]).round if others[:total].to_i.positive?
        others[:percent] = (others[:value].to_f / reviews_count * 100).ceil
        others[:color] = Analysis::COLORS.last
      end
      top + [others]
    end

    def source_query
      @source_query ||= base_reviews_query
        .select('sources.id, sources.name, sources.logo, 1 as percent, 1 as color, COUNT(reviews.id) AS count, AVG(reviews.rating) AS avg')
        .joins(:location)
        .joins('RIGHT OUTER JOIN sources ON reviews.source_id = sources.id AND reviews.location_id = locations.id')
        .group('sources.id, sources.name')
    end

    def sorted_source_query
      @sorted_source_query ||= source_query.with_rating.order('AVG(reviews.rating) DESC').to_a
    end
  end
end
