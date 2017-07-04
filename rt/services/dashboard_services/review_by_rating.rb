module DashboardServices
  module ReviewByRating
    def reviews_by_rating
      reviews_by_rating_without_html.each_with_index do |e, i|
        e[:rating_html] = rating(i)
        e[:rating] = rating_name(i)
        e[:y] = e[:count]
      end
    end

    def reviews_by_rating_without_html
      all_counts = [nil] * 6

      base_reviews_query
        .select('reviews.rating, COUNT(1) as amount')
        .group('reviews.rating')
        .each do |r|
        all_counts[r.rating.to_i] = { count: r.amount, name: r.rating }
      end

      reviews_by_rating = all_counts.map.with_index { |e, i| e.nil? ? { count: 0, name: i, percent: 0 } : e }
      count = reviews_count - reviews_by_rating[0][:count]
      if count.positive?
        reviews_by_rating.each_with_index do |e, index|
          reviews_by_rating[index][:percent] = (e[:count].to_f / count.to_f * 100).round
        end
        decrease_max_percent(reviews_by_rating) while percent_sum(reviews_by_rating) > 100
      end
      reviews_by_rating
    end

    private

    def rating_name(r)
      if r.nil? || r.zero?
        I18n.t('review.attributes.rating.nil')
      else
        "#{r}-Star"
      end
    end

    def percent_sum(reviews_by_rating)
      sum = 0
      reviews_by_rating.each_with_index { |e, index| sum += e[:percent] if index.positive? }
      sum
    end

    def decrease_max_percent(reviews_by_rating)
      reviews_by_rating.select{ |i| i[:name] }.max { |a, b| a[:percent] <=> b[:percent] }[:percent] -= 1
    end
  end
end
