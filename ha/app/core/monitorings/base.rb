module Monitorings
  class Base
    attr_accessor :monitoring, :domain, :data

    def initialize(monitoring)
      @monitoring = monitoring
      @domain = monitoring.domain
    end

    def call
      return unless can_check?
      @data = find_result
      Monitoring.transaction do
        create_history
        update_monitoring
        save_current_status
        update_domain
        track_status_change
        track_uptime_change
      end
    end

    private

    def find_result; end

    def can_check?
      !domain.inactive?
    end

    def create_history
      @monitoring.histories.create!(
        status: data[:status],
        error: data[:error_message],
        data: data
      )
    end

    def update_monitoring
      @monitoring.update!(monitoring_params)
    end

    def save_current_status; end

    def update_domain
      @domain.update!(domain_params)
    end

    def track_status_change; end

    def track_uptime_change; end

    def domain_params; end

    def monitoring_params
      params = {
        last_status: data[:status],
        last_error: data[:error_message],
        checked_at: Time.zone.now,
        consecutive_errors: consecutive_errors
      }
      params[:last_status_changed_at] = Time.zone.now if last_status_changed?
      params
    end

    def last_status_changed?
      return true if @monitoring.last_status_changed_at.nil? # first write always about changing a status
      data[:status]&.to_s != @monitoring.last_status
    end

    def consecutive_errors
      return 0 if data[:status] == :success
      @monitoring.consecutive_errors.to_i + 1
    end
  end
end
