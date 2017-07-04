module DashboardServices
  class Analysis
    include ApplicationHelper
    include DashboardServices::ReviewsDates
    include DashboardServices::ReviewByDate
    include DashboardServices::ReviewBySource
    include DashboardServices::ReviewByRating
    include DashboardServices::ReviewByLocation

    COLORS = %w(#8C84FF #D863CF #47D2C1 #FF782D #00B8FF #DDDDDD).freeze # TODO: add normal colors
    SOURCE_PIE_TOP_COUNT = 4

    attr_reader :customer, :user, :location, :posted_in, :group, :filters

    def initialize(customer, user, location_id: nil, last_months: '6', group_id: nil, date_range_start: nil, date_range_end: nil)
      @filters = {
        location_id: location_id,
        last_months: last_months,
        group_id: group_id,
        date_range_start: date_range_start,
        date_range_end: date_range_end
      }
      @customer = customer
      @user = user

      @location = customer.locations.find_by(id: location_id)
      @group = customer.location_groups.find_by(id: group_id)
      time_range(last_months, date_range_start, date_range_end)
    end

    def reviews_count
      @reviews_count ||= base_reviews_query.count
    end

    def base_reviews_query(posted_in = self.posted_in)
      Review.of_customer(customer).of_user_locations(user).of_location(location).of_location_group(group).posted_in(posted_in)
    end

    def reviews_count_query
      @reviews_query ||= base_reviews_query
        .select('AVG(reviews.rating) AS avg')
        .with_rating
        .to_a
        .first
    end
  end
end
