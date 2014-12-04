module Trailer
  module Store
    class << self
      def store(entity, id)
        model = load_model entity, id
        date, count = latest_hit entity, id
        trail = model.trails.daily.dated(date).first || model.trails.create(period: 'day', date: date)
        trail.update_attributes count: count
      end

      def latest_hit(entity, id)
        key = $redis.keys("#{entity}:#{id}:*:hit").sort.last
        matcher = key.match(/^#{entity}:\d+:(.+):hit$/)
        date = Date.parse matcher[1]
        value = $redis.GET(key)
        [date, value]
      end

      def load_model(model, id)
        model.to_s.camelize.constantize.send :find, id
      end
    end
  end
end
