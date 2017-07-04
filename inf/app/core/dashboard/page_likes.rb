module Dashboard
  class PageLikes < ::Dashboard::Base
    def calculate_new_page_likes(start_date: nil)
      data = base_history_query.day.for_interval(start_date)
        .group_by_day_of_week(:date).sum(:likes)

      data_by_days = day_names.map { |day| [day, 0] }.to_h

      data.each do |i, val|
        day_name = Date::DAYNAMES[i]
        data_by_days[day_name] = val
      end

      data_by_days
    end

    def day_names
      return @day_names if @day_names.present?
      @day_names = Date::DAYNAMES.dup
      @day_names.push(@day_names.pop)
      @day_names
    end
  end
end
