module Dashboard
  class SystemHistoryProvider
    def call
      data
    end

    def collection
      system_histories ||= SystemHistory
        .since_date(6.months.ago.in_time_zone.end_of_week)
        .order(date: :asc)

      return {} if system_histories.blank?
      CampaignsService.service_types.keys.map do |service|
        {
          name: service.upcase,
          data: system_histories.map { |item| [item.date.to_time.to_i * 1000, item.amounts[service].to_f] }
        }
      end
    end

    private

    def data
      amounts.merge(total: total, health: history&.health).map do |key, value|
        { key.to_sym => value.to_f }
      end.reduce(:merge)
    end

    def amounts
      return history.amounts if history&.amounts.present?
      CampaignsService.service_types.keys.map { |service| { service => 0 } }.reduce(:merge)
    end

    def history
      @history ||= SystemHistory.last
    end

    def total
      amounts.values.map(&:to_f).sum
    end
  end
end
