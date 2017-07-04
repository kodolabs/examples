class BraintreeService
  attr_reader :result

  def create_customer(email, nonce)
    @result = Braintree::Customer.create(
      email: email,
      credit_card: {
        payment_method_nonce: nonce,
        options: {
          verify_card: true,
          make_default: true
        }
      }
    )

    result_actions do
      customer = result.customer
      credit_card = customer.credit_cards.first

      [
        true,
        {
          braintree_id: customer.id,
          braintree_card_token: credit_card.token
        }
      ]
    end
  end

  def subscribe(card_token, plan_id)
    @result = Braintree::Subscription.create(
      payment_method_token: card_token,
      plan_id: plan_id
    )
    result_actions { [true, result.subscription.id] }
  end

  def update_subscription(id, args = {})
    defaults = { options: { prorate_charges: true } }

    @result = Braintree::Subscription.update(id,
      defaults.merge(args))

    result_actions { [true, @result.subscription] }
  end

  def update_customer_card(customer_id, nonce)
    @result = Braintree::PaymentMethod.create(
      customer_id: customer_id,
      payment_method_nonce: nonce,
      options: {
        make_default: true,
        verify_card: true
      }
    )
    result_actions do
      [
        true,
        {
          braintree_card_token: @result.payment_method.token
        }
      ]
    end
  end

  def cancel_subscription(id)
    @result = Braintree::Subscription.cancel(id)
    result_actions { true }
  end

  def refund(id, amount)
    @result = Braintree::Transaction.refund(id, amount)
    result_actions { true }
  end

  def create_add_ons(subscription, count)
    update_subscription(subscription.braintree_id, add_ons: {
      add: [
        {
          inherited_from_id: braintree_add_on_id(subscription),
          never_expires: true,
          quantity: count
        }
      ]
    })
  end

  def update_add_ons(subscription, count)
    update_subscription(subscription.braintree_id, add_ons: {
      update: [
        {
          existing_id: braintree_add_on_id(subscription),
          never_expires: true,
          quantity: count
        }
      ]
    })
  end

  def remove_add_ons(subscription)
    update_subscription(subscription.braintree_id, add_ons: {
      remove: [braintree_add_on_id(subscription)]
    })
  end

  def braintree_add_on_id(subscription = nil)
    subscription&.add_on&.braintree_id || ENV['BRAINTREE_ADD_ON_ID']
  end

  private

  def result_actions
    result.success? ? yield : report_errors(result)
  end

  def report_errors(result)
    message = result.credit_card_verification ? 'This card is invalid' : result.errors.map(&:message).join(', ')
    Rollbar.error result.errors.map(&:message).join(', ')
    Rails.logger.error result.errors.map(&:message).join(', ')
    [false, message]
  end
end
