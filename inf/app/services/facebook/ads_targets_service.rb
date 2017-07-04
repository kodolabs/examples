module Facebook
  class AdsTargetsService
    def initialize(account)
      @account = account
    end

    def search(type, q)
      return [] unless type.to_sym.in?(%i(interest location))
      send("search_#{type}", q)
    rescue Koala::Facebook::ClientError
      return []
    end

    private

    def search_interest(q)
      params = { type: 'adinterest', q: q }
      graph.graph_call('/search', params).map do |item|
        item.slice('id', 'name')
      end
    end

    def search_location(q)
      params = {
        type: 'adgeolocation',
        location_types: %w(country region city zip).to_json,
        q: q
      }
      graph.graph_call('/search', params).map do |item|
        item.slice('key', 'name', 'type', 'country_name', 'region')
      end
    end

    def graph
      @graph ||= Koala::Facebook::API.new(@account.token)
    end
  end
end
