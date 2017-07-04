module Cards
  class MakeDefault < Rectify::Command
    attr_reader :customer, :card

    def initialize(card)
      @customer = card.customer
      @card = card
    end

    def call
      update_on_stripe
      update_in_db
      broadcast(:ok)
    rescue Stripe::StripeError => e
      Rollbar.error(e)
      broadcast(:stripe_error)
    end

    private

    def update_on_stripe
      return true if customer.stripe_id.blank?
      stripe_customer.default_source = card.stripe_id
      stripe_customer.save
    end

    def stripe_customer
      @stripe_customer ||= Stripe::Customer.retrieve(customer.stripe_id)
    end

    def update_in_db
      card.update_attribute(:default, true)
      customer.cards.where.not(id: card.id).update_all(default: false)
    end
  end
end
