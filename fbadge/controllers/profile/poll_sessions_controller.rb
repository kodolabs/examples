class Profile::PollSessionsController < Profile::OrganiserBaseController
  before_action :find_poll
  before_action :find_session, only: :close

  def create
    session = @poll.poll_sessions.new
    flash = if session.save
      { success: 'Session succesfully created' }
    else
      { error: "Can't create a session" }
    end
    redirect_to profile_event_poll_path(@event, @poll, anchor: "session#{session.position}"), flash: flash
  end

  def close
    flash = if @session.closed!
      @session.update_attribute(:closed_at, DateTime.now)
      { success: 'Session succesfully closed' }
    else
      { error: "Can't close a session" }
    end
    redirect_to profile_event_poll_path(@event, @poll, anchor: "session#{@session.position}"), flash: flash
  end

  private

  def find_poll
    @poll = Poll.find(params[:poll_id])
  end

  def find_session
    @session = PollSession.find(params[:id])
  end
end
