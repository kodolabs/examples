module CustomersServices
  class StatusUpdate
    def initialize(customer, new_status)
      @customer = customer
      @new_status = new_status
    end

    def call
      success, error = change_status
      customer.errors.add(:base, error) unless success
      customer
    end

    private

    attr_reader :customer, :new_status

    def change_status
      return invalid_response if new_status == customer.status

      case new_status
      when 'active'
        CustomersServices::Enable.new(customer).perform
      when 'suspended'
        CustomersServices::Suspend.new(customer).perform
      when 'cancelled'
        CustomersServices::Cancel.new(customer, customer.subscription).perform
      else
        invalid_response
      end
    end

    def invalid_response
      [false, 'Invalid status']
    end
  end
end
