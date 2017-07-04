class Profile::TicketClassesController < Profile::OrganiserBaseController
  def index
    @ticket_classes = @event.ticket_classes.ordered
  end
end
