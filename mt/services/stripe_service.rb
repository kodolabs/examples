class StripeService
  attr_reader :patient, :token

  def initialize(patient = nil, token = nil)
    @patient = patient
    @token = token
  end

  def authorize
    return [false, nil] unless patient && token
    return create_customer unless patient.stripe_id

    customer = Stripe::Customer.retrieve(patient.stripe_id)
    card = customer.sources.create(source: token)

    [true, create_card(card)]
  rescue => e
    Rollbar.error e
    [false, nil]
  end

  def pay(payable, card)
    return [false, nil] unless payable && card && payable.can_charge?(patient)

    description = "Payment for #{payable.class} #{payable.id} from patient #{patient.email}"
    charge = charge(payable.price, card, description)

    payment = Payment.create(
      payable: payable,
      stripe_charge_id: charge.id,
      price: payable.price
    )

    [true, payment]
  rescue => e
    Rollbar.error e
    [false, nil]
  end

  def pay_cancellation_fee(enquiry)
    return true if enquiry.cancellation_fee.present?

    amount = Setting.cancellation_fee
    charge = charge(amount, @patient.default_card, '')

    enquiry.create_cancellation_fee(stripe_charge_id: charge.id, amount: amount)
    true
  rescue => e
    Rollbar.error e
    false
  end

  def refund(payment)
    return true unless payment && payment.refundable?

    charge = Stripe::Charge.retrieve(payment.stripe_charge_id)
    refund = charge.refunds.create amount: amount_in_cents(payment.price)

    payment.update(status: :refunded, stripe_refund_id: refund.id, error_message: '')
    true
  rescue => e
    Rollbar.error e
    payment.update_attribute(:error_message, e.message)
    false
  end

  private

  def create_customer
    customer = Stripe::Customer.create(
      source: token,
      email: patient.email
    )
    patient.update(stripe_id: customer.id)
    card = customer.sources.data[0]

    [true, create_card(card)]
  end

  def create_card(card)
    patient.credit_cards.create(stripe_card_id: card.id, last_four: card.last4, brand: card.brand)
  end

  def charge(price, card, description)
    Stripe::Charge.create(
      amount: amount_in_cents(price),
      currency: 'usd',
      customer: @patient.stripe_id,
      source: card.stripe_card_id,
      description: description
    )
  end

  def amount_in_cents(price)
    (price.to_f * 100).to_i
  end
end
