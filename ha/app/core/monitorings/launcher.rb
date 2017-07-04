module Monitorings
  class Launcher
    def call
      Monitorings::Enum.types.keys.each do |type|
        datetime = datetime_by_type(type)
        next if datetime.blank?

        Monitoring.by_type(type).joins(:domain)
          .merge(Domain.live)
          .need_check(datetime).each do |monitoring|
          RunMonitoringWorker.perform_async(monitoring.id)
        end
      end
    end

    private

    def datetime_by_type(type)
      return if Monitorings::Enum.frequencies[type].blank?
      Time.zone.now - Monitorings::Enum.frequencies[type]
    end
  end
end
