class Api::PollSessionsController < ActionController::Base
  def show
    @poll_session = PollSession.find(params[:poll_session_id])
    render json: @poll_session.extend(::PollSessions::ResultRepresenter)
  end

  def create
    Api::PollSessions::Create.call(params) do
      on(:ok) { |poll_session| render json: poll_session }
      on(:invalid) { |error| render json: error, status: 400 }
    end
  end

  def update
    Api::PollSessions::Close.call(params) do
      on(:ok) { |poll_session| render json: poll_session }
      on(:invalid) { |error| render json: error, status: 400 }
    end
  end
end
