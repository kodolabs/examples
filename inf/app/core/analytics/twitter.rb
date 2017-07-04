module Analytics
  class Twitter < ::Analytics::Base
    MIN_INTERVAL = 1.week

    attr_reader :favorites_data, :retweets_data, :page, :chart_data, :pages_collection

    def call
      set_filter_data
      set_page_data
    end

    def show_blank?
      @customer.twitter_accounts.blank?
    end

    def show_filter?
      !show_blank?
    end

    def recent_posts
      @page.posts.includes(:images).recent.limit(POSTS_LIMIT).decorate
    end

    def chartjs_data
      return nil if empty_data?(favorites_data) || empty_data?(retweets_data)

      {
        favorites_data: {
          values: favorites_data.try(:values),
          labels: favorites_data.try(:keys)
        },
        retweets_data: {
          values: retweets_data.try(:values),
          labels: retweets_data.try(:keys)
        }
      }
    end

    private

    def posts_history
      History.for_page(@page.id).day
    end

    def page_id
      @page.id
    end

    def set_page_data
      return if show_blank?

      @page = @params[:page_id].presence ? Page.find(@params[:page_id]) : @pages.first
      return set_demo_data if @customer.demo?
      empty_data = empty_data_for(start_date)
      data = posts_history.for_interval(start_date).group_by_day(:date, time_zone: 'UTC')
      @favorites_data = empty_data.merge data.sum(:likes)
      @retweets_data = empty_data.merge data.sum(:shares)
    end

    def set_filter_data
      @pages = @customer.pages.twitter.ordered || []
      @pages_collection = @pages.presence ? @pages.decorate.map { |p| [p.full_handle, p.id] } : []
    end

    def start_date
      last_date = posts_history.order(date: :asc).for_interval(START_DATE).first.try(:date)
      last_date && last_date < MIN_INTERVAL.ago ? last_date : MIN_INTERVAL.ago
    end

    def empty_data?(data)
      data.blank? || data.try(:values).try(:all?, &:zero?)
    end

    def demo_data
      Rails.cache.fetch(cache_key) do
        OpenStruct.new(
          favorites_data: generate_demo_data,
          retweets_data: generate_demo_data
        )
      end
    end

    def set_demo_data
      @favorites_data = demo_data.favorites_data
      @retweets_data = demo_data.retweets_data
    end
  end
end
