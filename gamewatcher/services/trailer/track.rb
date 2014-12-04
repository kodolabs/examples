module Trailer
  module Track
    class << self
      def reset(entity, id)
        $redis.SET timed_key(entity, id), 0
      end

      def hit(entity, id)
        $redis.EXPIRE timed_key(entity, id), 2.days
        $redis.INCR timed_key(entity, id)
      end

      def get(entity, id)
        $redis.GET timed_key(entity, id)
      end

      def timed_key(entity, id, date = nil)
        date ||= Date.today.to_s
        "#{entity}:#{id}:#{date}:hit"
      end
    end
  end
end
