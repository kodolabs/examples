module DashboardServices
  module ReviewByDate
    def reviews_by_date
      @reviews_by_date ||= begin
        main_query = Review.find_by_sql([<<-SQL.squish, first_review_date(posted_in_for_select), reviews_date_to, present_dates])
      SELECT date, COUNT(reviews.truncated_date) as amount
      FROM generate_series(?, ?, '1 month'::interval) AS date
      LEFT OUTER JOIN (?) AS reviews
      ON reviews.truncated_date = date
      GROUP BY date
      ORDER BY date
        SQL

        calculate_diff_by_date(main_query) do |r|
          { date: r.date.strftime('%b %Y'), count: r.amount, draw: 1, orig_date: r.date }
        end
      end
    end

    def average_rating_by_date
      main_query = Review.find_by_sql([<<-SQL.squish, first_review_date(posted_in_for_select), reviews_date_to, present_dates(false)])
      SELECT date, AVG(reviews.rating) as amount
      FROM generate_series(?, ?, '1 month'::interval) AS date
      LEFT OUTER JOIN (?) AS reviews
      ON reviews.truncated_date = date
      GROUP BY date
      ORDER BY date
      SQL

      calculate_diff_by_date(main_query) do |r|
        { date: r.date.strftime('%b %Y'), average: r.amount.to_f.round(2), draw: 1, orig_date: r.date, count: r.amount.to_f.round(2) }
      end
    end

    def calculate_diff_by_date(main_query)
      previous_month_amount = 0
      res = main_query.map do |r|
        res = yield r
        if previous_month_amount.to_f.positive? && r.amount.to_f.positive?
          diff = r.amount.to_f - previous_month_amount
          res[:diff] = (diff.to_f / previous_month_amount * 100).ceil
        end
        previous_month_amount = r.amount.to_f
        res
      end
      res.each(&calc_draw_rule) if posted_in
      res
    end

    def calc_draw_rule
      @calc_draw_rule ||= lambda do |row|
        if draw_dates.include?(row[:orig_date])
          row[:draw] = 1
          row[:drawLine] = 1 unless posted_in.include?(row[:orig_date])
        else
          row[:draw] = 0
        end
      end
    end
  end
end
