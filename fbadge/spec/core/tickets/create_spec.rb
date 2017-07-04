require 'rails_helper'

describe Tickets::Create do
  context 'ticket' do
    specify 'should successfully created' do
      user = create(:user, :organiser)
      event = create(:event, :active, creator: user)
      profile = create(:profile, :organiser, event: event, user: user)
      ticket_class = create(:ticket_class, event: event)
      barcode = '123321'
      expect(Ticket.count).to eq 0
      Tickets::Create.new(profile, ticket_class, barcode, user).call
      expect(Ticket.count).to eq 1
    end
  end
end
