module Analytics
  class Facebook < ::Analytics::Base
    MIN_INTERVAL = 2.months

    attr_reader :facebook_account, :pages, :pages_collection, :interactions_data, :page, :chart_data

    def call
      @facebook_account = @customer.facebook_account

      set_filter_data
      set_page_data
    end

    def show_blank?
      @facebook_account.blank? || @pages.blank?
    end

    def show_filter?
      @facebook_account && @pages.present?
    end

    def recent_posts
      @page.posts.includes(:images).recent.limit(POSTS_LIMIT).decorate
    end

    def chartjs_data
      {
        interactions_data: {
          values: interactions_data.try(:values),
          labels: interactions_data.try(:keys)
        }
      }
    end

    private

    def set_filter_data
      @pages = @facebook_account.try(:pages).try(:ordered) || []
      @pages_collection = @pages.presence ? @pages.decorate.map { |p| [p.full_handle, p.id] } : []
    end

    def page_id
      @page_id ||= @params[:page_id].presence ? @params[:page_id] : @pages.first.try(:id)
    end

    def set_page_data
      return if page_id.blank?
      @page = @pages.includes(:histories).find_by(id: page_id)
      return if start_date.nil?
      return set_demo_data if @customer.demo?

      empty_data = empty_data_for(start_date)
      data = empty_data.merge @page.histories
        .day
        .for_interval(start_date)
        .group_by_month(:date)
        .sum(:engaged_users)
      @interactions_data = format_data(data)
    end

    def start_date
      @last_date ||= @page.histories.day.order(date: :asc).for_interval(START_DATE)
        .where.not(engaged_users: 0).first.try(:date)

      @last_date && @last_date < MIN_INTERVAL.ago ? @last_date : MIN_INTERVAL.ago
    end

    def format_data(data)
      if data.blank? || data.try(:values).try(:all?, &:zero?)
        nil
      else
        data
      end
    end

    def demo_data
      Rails.cache.fetch(cache_key) { generate_demo_data }
    end

    def set_demo_data
      @interactions_data = demo_data
    end
  end
end
