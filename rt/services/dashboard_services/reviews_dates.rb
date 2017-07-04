module DashboardServices
  module ReviewsDates
    TRUNCATED_DATE = "date_trunc('month', reviews.posted_at)::date AS truncated_date".freeze

    def draw_dates
      @draw_dates ||= Range.new(posted_in.first, 1.month.since(posted_in.last))
    end

    def present_dates(include_nil_rating = true)
      relation = base_reviews_query(posted_in_for_select)
      if include_nil_rating
        relation.select(DashboardServices::ReviewsDates::TRUNCATED_DATE)
      else
        relation.with_rating.select("#{DashboardServices::ReviewsDates::TRUNCATED_DATE}, rating")
      end
    end

    def posted_in_for_select
      @posted_in_for_select ||= Range.new(1.month.ago(posted_in.first), 2.months.since(posted_in.last)) if posted_in
    end

    def posted_dates_distance
      @posted_dates_distance ||= begin
        date2 = posted_in.last
        date1 = posted_in.first
        (date2.year * 12 + date2.month) - (date1.year * 12 + date1.month)
      end if posted_in
    end

    def first_review_date(posted_in = self.posted_in)
      return posted_in.first.beginning_of_month if posted_in

      date = base_reviews_query.order(:posted_at).select(:posted_at).first
      date ? date.posted_at.beginning_of_month : Date.today
    end

    def reviews_date_to
      posted_in ? posted_in_for_select.last : Date.today
    end

    private

    def time_range(last_months, date_range_start, date_range_end)
      if last_months.to_i == -1 && date_range_start && date_range_end
        @posted_in = Range.new(Date.parse(date_range_start).beginning_of_month, Date.parse(date_range_end))
        return
      end
      return unless last_months =~ /\A\d+\z/

      @posted_in = (last_months.to_i - 1).months.ago.to_date.beginning_of_month..Date.today
    end
  end
end
