class EventbriteController < ApplicationController
  skip_before_action :verify_authenticity_token

  def event_updated
    Integrations::Eventbrite::SyncTicketClass.call(params)
    head :ok
  end

  def order_placed
    Integrations::Eventbrite::CreateTicket.call(params)
    head :ok
  end
end
