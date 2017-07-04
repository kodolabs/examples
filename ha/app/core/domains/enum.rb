module Domains
  class Enum
    def self.statuses
      { pending: 0, active: 1, quarantine: 2, zombie: 3, inactive: 4 }
    end

    def self.uptime_statuses
      { uptime_unknown: 0, success: 1, unavailable: 2, error: 3 }
    end

    def self.index_statuses
      { index_unknown: 0, indexed: 1, not_indexed: 2 }
    end

    def self.hack_statuses
      { hack_unknown: 0, good: 1, hacked: 2 }
    end

    def self.expiration_statuses
      {
        expiration_unknown: 0,
        expiration_empty: 1,
        expiration_ok: 2,
        manual: 3
      }
    end

    def self.sources
      {
        scrape: 0,
        vendor: 1,
        drop: 2,
        other: 3
      }
    end
  end
end
