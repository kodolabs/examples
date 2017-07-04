module Monitorings
  class ChartProvider
    attr_accessor :monitoring, :date
    DATE_PERIOD = 30

    def initialize(domain, type)
      @date = Time.zone.today - DATE_PERIOD.days
      @monitoring = domain.monitorings.by_type(type).first
    end

    def call
      res = [
        [date_value(date), nil]
      ]

      prepader_data.map do |history|
        res << [
          date_value(history.created_at.to_date),
          row_value(history)
        ]
      end
      res
    end

    def data
      monitoring.histories.since(date).ordered_asc
    end

    def prepader_data
      data
    end

    def date_value(date)
      date.to_s.to_time(:utc).to_i * 1000
    end

    def row_value(_record)
      raise 'Need implement `row_value` method'
    end
  end
end
