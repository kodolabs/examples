module Monitorings
  class Whois < Monitorings::Base
    private

    def find_result
      @parser ||= ::Whois.whois(@domain.name).parser
      { expires_at: @parser&.expires_on&.to_date, status: monitoring_status }
    rescue => e
      { error_message: e.message, status: monitoring_status }
    end

    def domain_params
      if data[:expires_at].blank?
        return {} if domain.expiration_status == 'manual'
        { expiration_status: :expiration_empty }
      else
        {
          expires_at: data[:expires_at],
          expiration_status: :expiration_ok
        }
      end
    end

    def monitoring_status
      @status ||= if @parser.blank?
        :empty
      elsif @parser&.expires_on.blank?
        :error
      else
        :success
      end
    rescue
      :error
    end
  end
end
