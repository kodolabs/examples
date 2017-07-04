module Cards
  class Delete < Rectify::Command
    attr_reader :customer, :card

    def initialize(card)
      @customer = card.customer
      @card = card
    end

    def call
      return broadcast(:last_card_error) if last_card?
      return broadcast(:stripe_error) unless delete_on_stripe
      check_default
      card.destroy!
      broadcast(:ok)
    rescue Stripe::StripeError => e
      Rollbar.error(e)
      broadcast(:stripe_error)
    rescue
      broadcast(:error)
    end

    private

    def last_card?
      customer.cards.count == 1
    end

    def delete_on_stripe
      return true if customer.stripe_id.blank?
      stripe_customer.sources.retrieve(card.stripe_id).delete['deleted']
    end

    def stripe_customer
      @stripe_customer ||= Stripe::Customer.retrieve(customer.stripe_id)
    end

    def check_default
      return unless card.default?
      Cards::MakeDefault.call(new_default_card)
    end

    def new_default_card
      customer.cards.ordered.where.not(id: card.id).first
    end
  end
end
