module Api
  module PollSessions
    class Close < Rectify::Command
      def initialize(params)
        @params = params
      end

      def call
        session = find_poll_session
        if session.active?
          close_poll_session(session)
        else
          broadcast(:invalid, session.errors.extend(::PollSessions::ErrorsRepresenter))
        end
      rescue => e
        return broadcast(:invalid, e.extend(::PollSessions::ErrorsRepresenter))
      end

      private

      def find_poll_session
        PollSession.find(@params[:poll_session_id])
      end

      def close_poll_session(session)
        session.update(status: :closed, closed_at: DateTime.now)
        broadcast(:ok, session.extend(::PollSessions::CloseRepresenter))
      end
    end
  end
end
