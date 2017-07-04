module Dashboard
  class Header < ::Dashboard::Base
    HEADER_PERIOD = 1.week
    HEADER_START_DATE = 2.weeks

    def page_likes
      insights_data_for :likes, :day
    end

    def click_rate
      insights_data_for :engaged_users, :day
    end

    def paid_connections
      insights_data_for :paid_connections, :day
    end

    def connections
      insights_data_for :connections, :day
    end

    def total_males
      insights_data_for :males, :day
    end

    def total_females
      insights_data_for :females, :day
    end

    def header_sections
      [
        { page_likes: 'Page likes' },
        { click_rate: 'Click rate' },
        { total_males: 'Total Males' },
        { total_females: 'Total Females' },
        { total_paid_connections: 'Paid Connections' },
        { total_connections: 'Total Connections' }
      ]
    end

    private

    def insights_data_for(field, period)
      return demo.header_data_for(field) if @customer.demo?
      query = header_history_query
      day_start = HEADER_PERIOD.send(:ago).beginning_of_day

      current_query = query.for_interval(day_start)
      prev_query = query.for_interval(header_start_date, day_start)

      current_values = group_insights_data(current_query, field: field, period: period)
      prev_values = group_insights_data(prev_query, field: field, period: period)

      current_count, prev_count = if period == :lifetime
        [current_values.last - current_values.first, prev_values.last - prev_values.first]
      else
        [current_values.inject(:+), prev_values.inject(:+)]
      end.map(&:to_i)

      {
        percentage: percentage(current_count - prev_count, prev_count).round.to_i,
        total_count: current_count
      }
    end

    def header_start_date
      HEADER_START_DATE.send(:ago).beginning_of_day
    end

    def header_history_query
      base_history_query.for_interval(header_start_date)
    end
  end
end
