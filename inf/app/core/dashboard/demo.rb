module Dashboard
  class Demo < ::Dashboard::Base
    def header_data_for(field)
      cache_key = cache_key_for(field)
      Rails.cache.fetch(cache_key) do
        {
          percentage: rand(10..90),
          total_count: rand(2000..8000)
        }
      end
    end

    def social_presence_data
      cache_key = cache_key_for('social_presence')
      Rails.cache.fetch(cache_key) do
        from = 1.week.ago.to_date
        to = Time.zone.today
        labels, values = (from..to).map do |date|
          [date, rand(100..200)]
        end.transpose

        { labels: labels, values: values }
      end
    end

    def new_page_likes
      cache_key = cache_key_for('new_page_likes')
      Rails.cache.fetch(cache_key) do
        page_likes_service.day_names.map { |day| [day, rand(20..100)] }.to_h
      end
    end

    def demographics
      cache_key = cache_key_for('demographics')

      Rails.cache.fetch(cache_key) do
        first_range = rand(5..10)
        second_range = rand(5..10)
        fourth_range = rand(5..10)
        five_range = rand(5..10)
        six_range = rand(5..10)
        seven_range = rand(5..10)
        sum = (first_range + second_range + fourth_range + five_range + six_range + seven_range)
        third_range = 100 - sum

        {
          '13-17' => first_range,
          '18-24' => second_range,
          '25-34' => third_range,
          '35-44' => fourth_range,
          '45-54' => five_range,
          '55-64' => six_range,
          '65+' => seven_range
        }
      end
    end

    def locations
      cache_key = cache_key_for('locations')

      Rails.cache.fetch(cache_key) do
        second_range = rand(10..30)
        third_range = rand(10..30)
        fourth_range = rand(10..30)
        first_range = 100 - (second_range + third_range + fourth_range)

        {
          'Australia' => first_range,
          'USA' => second_range,
          'England' => third_range,
          'France' => fourth_range
        }
      end
    end

    def views
      cache_key = cache_key_for('views')
      Rails.cache.fetch(cache_key) do
        rand(5000..10_000)
      end
    end

    private

    def cache_key_for(field)
      time = Time.zone.today.beginning_of_day.to_i
      "#{@customer.id}/demo/dashboard/#{time}/#{field}"
    end
  end
end
