module Analytics
  class Base
    MESSAGE = 'ERROR: Method not implemented'.freeze
    START_DATE = Time.current.beginning_of_year
    POSTS_LIMIT = 3

    def initialize(customer, params)
      @customer = customer
      @params = params
    end

    def chartjs_data
      raise MESSAGE
    end

    protected

    def generate_demo_data
      range = 1.year.ago.beginning_of_month.to_date..Time.zone.today
      range.map { |d| [d.beginning_of_month, rand(10..200)] }.to_h
    end

    def empty_data_for(date)
      ((date.beginning_of_month.to_date)..Time.zone.today).map { |d| [d.beginning_of_month, 0] }.to_h
    end

    def cache_key
      time = Time.zone.today.beginning_of_day.to_i
      provider = self.class.to_s.demodulize.downcase
      "#{@customer.id}/demo/#{provider}/#{page_id}#{time}"
    end
  end
end
