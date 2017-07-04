module Monitorings
  class Runner
    attr_accessor :monitoring

    def initialize(monitoring)
      @monitoring = monitoring
    end

    delegate :call, to: :create_instance

    private

    def create_instance
      case monitoring.monitoring_type
      when 'whois'
        Monitorings::Whois.new monitoring
      when 'uptime'
        Monitorings::Uptime.new monitoring
      when 'indexed'
        Monitorings::Index.new monitoring
      when 'hack'
        Monitorings::Hack.new monitoring
      else
        raise "Invalid type `#{monitoring.monitoring_type}`"
      end
    end
  end
end
