class Profile::TicketsController < Profile::OrganiserBaseController
  def index
    @tickets = @event.tickets.ordered
  end
end
