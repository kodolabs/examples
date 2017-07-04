module Monitorings
  class Uptime < Monitorings::Base
    ALLOWED_HTTP_CODES = 200..226

    private

    def find_result
      @http_code = RestClient.get(@domain.name)&.code
      {
        status: monitoring_status,
        http_code: @http_code,
        error_message: @error_message
      }
    rescue RestClient::ExceptionWithResponse => e
      @http_code = e.response&.code
      {
        status: monitoring_status,
        http_code: @http_code,
        error_message: e.message
      }
    rescue => e
      { status: :error, error_message: e.message }
    end

    def track_uptime_change
      Domains::TrackUptimeChange.call(domain: @domain)
    end

    def domain_params
      { uptime_status: { failure: :unavailable }.fetch(data[:status], data[:status]) }
    end

    def monitoring_status
      if @http_code.blank?
        :error
      elsif invalid_http_code?
        :failure
      else
        :success
      end
    end

    def invalid_http_code?
      return false if ALLOWED_HTTP_CODES.include?(@http_code)
      @error_message = I18n.t('notifications.invalid_http_code', code: @http_code)
      true
    end
  end
end
