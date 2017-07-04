module DashboardServices
  module ReviewByLocation
    SHOW_COUNT = 5

    def base_reviews_by_location_query
      base_reviews_query
        .joins(:location)
        .group('locations.name, locations.id')
        .order('locations.name')
        .select(<<-SQL.squish)
          locations.id, locations.name,
          #{star_filters}
          COUNT(1) AS count,
          COUNT(CASE WHEN reviews.status = 0 THEN 1 ELSE NULL END) AS new_count,
          AVG(reviews.rating) AS avg
      SQL
    end

    private

    def star_filters
      star_filters = ''

      Range.new(1, FeedbackServices::RecalculateRating::INNER_RATING).each do |number|
        star_filters << "COUNT(CASE WHEN reviews.rating = #{number} THEN 1 ELSE NULL END) AS star_#{number},"
      end

      star_filters
    end
  end
end
