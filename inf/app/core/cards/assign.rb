module Cards
  class Assign < Rectify::Command
    attr_reader :customer, :card

    def initialize(customer, card)
      @customer = customer
      @card = card
    end

    def call
      stripe_customer.sources.create(source: card.stripe_token)
      broadcast(:ok)
    rescue Stripe::StripeError => e
      Rollbar.error(e)
      broadcast(:stripe_error)
    end

    private

    def stripe_customer
      @stripe_customer ||= Stripe::Customer.retrieve(customer.stripe_id)
    end
  end
end
