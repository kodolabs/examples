module Monitorings
  class UptimeProvider < ChartProvider
    def prepader_data
      res = {}
      data.each do |r|
        if res[r.created_at.to_date].blank?
          res[r.created_at.to_date] = OpenStruct.new(
            created_at: r.created_at,
            success: 0,
            total: 0
          )
        end
        res[r.created_at.to_date].success += 1 if r.success?
        res[r.created_at.to_date].total += 1
      end
      res.values
    end

    def row_value(record)
      return 0 if record.total.zero?
      ((record.success * 100.0) / record.total).round(1)
    end
  end
end
