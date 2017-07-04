module CustomersServices
  class Enable < ActionSequence
    attr_reader :customer

    # @param [Customer] customer
    def initialize(customer)
      @customer = customer
      super(%w(resume_connections persist))
    end

    private

    def resume_connections
      @success = Harvester.resume customer.connections.pluck(:watch_id)
    end

    def persist
      @success = customer.update!(suspended_at: nil, status: Customer::STATUS_ACTIVE)
    end
  end
end
