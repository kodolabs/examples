module Monitorings
  class IndexProvider < ChartProvider
    def prepader_data
      res = {}
      data.each do |r|
        if res[r.created_at.to_date].blank?
          res[r.created_at.to_date] = OpenStruct.new(
            created_at: r.created_at,
            pages_count: 0
          )
        end
        res[r.created_at.to_date].pages_count = [
          res[r.created_at.to_date].pages_count,
          r.data.fetch('pages_count', 0)
        ].max
      end
      res.values
    end

    def row_value(record)
      record.pages_count
    end
  end
end
