module CustomersServices
  class Suspend < ActionSequence
    attr_reader :customer

    def initialize(customer)
      @customer = customer
      super(%w(suspend_connections persist))
    end

    private

    def suspend_connections
      @success = Harvester.pause customer.connections.where.not(watch_id: nil).pluck(:watch_id)
    end

    def persist
      @success = customer.update!(suspended_at: Time.zone.now, status: Customer::STATUS_SUSPENDED)
    end
  end
end
