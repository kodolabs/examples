module Dashboard
  class Demographics < ::Dashboard::Base
    def user_demographics
      return demo.demographics if @customer.demo?
      @user_demographics ||= calculate_user_demographics(demographics.engaged)
    end

    def visitors_location
      return demo.locations if @customer.demo?
      @visitors_location ||= calculate_user_location(demographics.reached)
    end

    private

    def calculate_user_demographics(records)
      calculate_data(records, :gender).sort_by { |k, _v| k }.to_h
    end

    def calculate_user_location(records)
      calculate_data(records, :location).sort_by { |_k, v| v }.reverse.to_h
    end

    def calculate_data(records, data_type)
      collected_data = {}

      records.each do |record|
        data = demographics_data_for(record, data_type)

        data.each do |key, value|
          collected_key = collected_key_for(key, data_type)
          collected_data[collected_key] ||= 0
          collected_data[collected_key] += value
        end
      end

      total_sum = collected_data.values.inject(:+)
      collected_data.map { |k, v| [k, percentage(v, total_sum).round] }
    end

    def collected_key_for(val, data_type)
      case data_type
      when :gender
        val.split('.').last
      when :location
        ISO3166::Country.new(val).name
      end
    end

    def demographics_data_for(record, data_type)
      case data_type
      when :gender
        record.genders
      when :location
        record.countries
      end
    end
  end
end
