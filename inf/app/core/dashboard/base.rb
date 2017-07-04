module Dashboard
  class Base
    POSTS_LIMIT = 3 # Recent posts
    MAX_PAGE_LIKES = 200 # Page likes max value for percent lines
    MAX_PAGE_LIKES_DAYS = 5 # Page likes days limit

    PAGE_LIKES_START_DATE = 1.month
    SOCIAL_PRESENCE_START_DATE = 1.week

    def initialize(customer)
      @customer = customer
    end

    def demo
      @demo_service ||= ::Dashboard::Demo.new(@customer)
    end

    def header_service
      @header_service ||= Dashboard::Header.new(@customer)
    end

    def demographics_service
      @demographics_service ||= Dashboard::Demographics.new(@customer)
    end

    def page_likes_service
      @page_likes_service ||= Dashboard::PageLikes.new(@customer)
    end

    delegate :user_demographics, to: :demographics_service
    delegate :visitors_location, to: :demographics_service

    def social_presence_data(from: nil, to: nil)
      return demo.social_presence_data if @customer.demo?

      from ||= Date.current - 1.week
      to ||= Date.yesterday
      raw_data = base_history_query.day.for_interval(from, to + 1.day)
        .group_by_day(:date).sum(:likes)
      labels, values = (from..to).map do |date|
        [date, raw_data.fetch(date, 0)]
      end.transpose
      { labels: labels, values: values }
    end

    def recent_posts
      @recent_posts ||= Post.includes(:page).for_customer(@customer.id)
        .facebook.recent.limit(POSTS_LIMIT).decorate
    end

    def total_views
      return demo.views if @customer.demo?
      @total_views ||= base_history_query.days_28.where(date: last_history_date).sum(:views)
    end

    def user_demographics_colors
      {
        blue: '#3498DB', green: '#43bfa9', purple: '#9B59B6',
        aero: '#9CC2CB', red: '#E74C3C', yellow: 'yellow',
        grey: 'grey'
      }
    end

    def new_page_likes
      return demo.new_page_likes if @customer.demo?
      @new_pages_likes ||= page_likes_service.calculate_new_page_likes(
        start_date: Date.current - PAGE_LIKES_START_DATE
      )
    end

    def header
      {
        page_likes: header_service.page_likes,
        click_rate: header_service.click_rate,
        total_connections: header_service.connections,
        total_paid_connections: header_service.paid_connections,
        total_males: header_service.total_males,
        total_females: header_service.total_females
      }
    end

    delegate :header_sections, to: :header_service

    def max_page_likes
      MAX_PAGE_LIKES
    end

    def percentage(number, n)
      return 0 if number.zero? && n.zero?
      return 100 if n.zero?

      number.to_f / n.to_f * 100.0
    end

    private

    def base_history_query
      @base_history_query ||= History.for_customer(@customer.id)
    end

    def base_demographics_query
      @base_demographics_query ||= Demographic.for_customer(@customer.id)
    end

    def group_insights_data(query, options)
      field = options[:field]
      period = options[:period]
      query.send(period).group_by_day(:date).sum(field).sort_by(&:first).map(&:last)
    end

    def demographics
      @demographics ||= base_demographics_query.where(date: last_demographic_date)
    end

    def last_history_date
      @last_history_date ||= base_history_query.days_28.ordered.first&.date
    end

    def last_demographic_date
      @last_demographic_date ||= base_demographics_query.ordered.first&.date
    end
  end
end
