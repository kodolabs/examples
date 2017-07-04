module Shares
  class ShareAutoForm < ShareForm
    def auto
      true
    end

    def date
      schedule_time.strftime('%d/%m/%Y')
    end

    def time
      schedule_time.strftime('%I:%M %p')
    end

    def targets
      customer.owned_pages.map do |p|
        [
          p.id, { 'id' => p.id, 'source' => p.provider.name, 'checked' => true }
        ]
      end.to_h
    end

    private

    def schedule_time
      date = first_free_date
      return prepare_time(date, '12:45PM') unless date == Date.current
      %w(12:45PM 4:45PM).each do |time_str|
        time = prepare_time(date, time_str)
        return time if Time.current < time # TODO: dangerous when now close to threshold
      end
      prepare_time(first_free_date(start_date: date + 1.day), '12:45PM')
    end

    def prepare_time(date, time_str)
      Time.zone.parse("#{date.strftime('%d-%m-%Y')} #{time_str}")
    end

    def first_free_date(start_date: Date.current)
      end_date = (busy_dates.last || Date.current) + 1.day
      (start_date..end_date).each { |d| return d unless d.in?(busy_dates) }
    end

    def busy_dates
      @busy_dates ||= customer.shares.pluck(:scheduled_at, :created_at).map do |s, c|
        d = (s || c).to_date
        d if d >= Date.current
      end.compact.sort.uniq
    end
  end
end
