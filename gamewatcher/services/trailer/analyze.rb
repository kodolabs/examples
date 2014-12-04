module Trailer
  module Analyze
    class << self
      def count(entity, id)
        model = Trailer::Store.load_model entity, id

        ranges = {
            week: 6,          # 7 including today
            month: 29,        # 30 including today
            three_months: 89, # 90 including today
            two_weeks: 13     # 14 including today
        }

        counter = model.counter || model.create_counter

        counter.overall = model.trails.select('SUM(count) AS sum_count').group('trailable_id')[0].sum_count
        ranges.each do |period, days|
          res = model.trails.recent(days).select('SUM(count) AS sum_count').group('trailable_id')[0]
          counter.send "#{period}=", res.sum_count
        end
        counter.save
        counter
      end
    end
  end
end
