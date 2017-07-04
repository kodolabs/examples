module Dashboard
  class BaseRecentClientsProvider
    def call
      clients_collection.map do |client|
        {
          name: client.name,
          url: helper.client_path(client),
          amount: amount(client),
          date: date(client)
        }
      end
    end

    private

    def amount(client)
      Rails.cache.fetch("#{client.cache_key}_amount") do
        calculate(client)
      end
    end

    def helper
      @helper ||= Class.new do
        include Rails.application.routes.url_helpers
      end.new
    end
  end
end
