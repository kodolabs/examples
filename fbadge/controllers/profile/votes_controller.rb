class Profile::VotesController < Profile::OrganiserBaseController
  before_action :find_poll, only: [:generate]

  def generate
    flash = VoteService.new(params[:session_id]).generate
    redirect_to profile_event_poll_path(@event, @poll, anchor: "session#{session_position}"), flash: flash
  end

  private

  def find_poll
    @poll = @event.polls.find(params[:poll_id])
  end

  def session_position
    @poll.poll_sessions.find(params[:session_id]).position
  end
end
