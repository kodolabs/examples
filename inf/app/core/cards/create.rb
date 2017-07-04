module Cards
  class Create < Rectify::Command
    attr_reader :form, :customer, :card

    def initialize(form, customer)
      @form = form
      @customer = customer
    end

    def call
      return broadcast(:invalid, form) if form.invalid?
      @card = customer.cards.new(form.attributes)
      return broadcast(:invalid, form) unless card.save
      return broadcast(:stripe_error) unless assign_stripe_card
      Cards::MakeDefault.call(card)
      broadcast(:ok)
    end

    private

    def assign_stripe_card
      return true if @customer.stripe_id.blank?
      Cards::Assign.call(customer, card)
    end
  end
end
