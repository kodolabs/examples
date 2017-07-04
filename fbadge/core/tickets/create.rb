module Tickets
  class Create < Rectify::Command
    def initialize(profile, ticket_class, barcode, buyer)
      @profile = profile
      @ticket_class = ticket_class
      @barcode = barcode
      @buyer = buyer
    end

    def call
      Ticket.create(
        profile: @profile,
        ticket_class: @ticket_class,
        barcode: @barcode,
        buyer_id: @buyer.id
      )
    end
  end
end
