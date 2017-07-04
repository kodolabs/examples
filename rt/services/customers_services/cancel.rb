module CustomersServices
  class Cancel < ActionSequence
    attr_reader :customer, :subscription, :braintree, :amount, :sorted_transactions

    def initialize(customer, subscription)
      @customer = customer
      @subscription = subscription
      if @subscription&.braintree_id.present?
        @braintree = BraintreeService.new
        super(%w(nullify_subscription refund cancel_subscription persist))
      else
        super(%w(persist))
      end
    end

    private

    def nullify_subscription
      @success, @details = braintree.update_subscription(subscription.braintree_id, price: 0.0)
    end

    def refund
      return if @details.transactions.empty?

      @amount = @details.status_history.first.balance.to_f * -1
      @sorted_transactions = @details.transactions.sort_by { |t| t.amount.to_f }.reverse!

      refund_transaction
    end

    def refund_transaction
      transaction = sorted_transactions.pop
      continue = amount > transaction.amount.to_f
      amount_to_refund =  continue ? transaction.amount : amount
      @success = braintree.refund(transaction.id, amount)

      return unless continue

      @amount = amount - amount_to_refund
      refund_transaction
    end

    def cancel_subscription
      @success = braintree.cancel_subscription(subscription.braintree_id)
    end

    def persist
      @success = customer.update!(canceled_at: Time.zone.now, status: Customer::STATUS_CANCELLED)
    end
  end
end
