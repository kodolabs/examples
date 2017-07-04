module Monitorings
  class Enum
    def self.statuses
      { empty: 0, success: 1, error: 2, failure: 3 }
    end

    def self.types
      { whois: 0, uptime: 1, indexed: 2, hack: 3 }
    end

    def self.frequencies
      {
        whois: nil,
        uptime: 2.hours,
        indexed: 1.day,
        hack: 1.day
      }
    end
  end
end
