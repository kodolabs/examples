module Dashboard
  class NumberClientsProvider
    def call
      {
        active: active_count,
        inactive: inactive_count
      }
    end

    private

    def active_count
      Rails.cache.fetch('clients_active_count', expires_in: 4.hours) do
        Client.active.count
      end
    end

    def inactive_count
      Rails.cache.fetch('clients_inactive_count', expires_in: 4.hours) do
        Client.inactive.count
      end
    end
  end
end
