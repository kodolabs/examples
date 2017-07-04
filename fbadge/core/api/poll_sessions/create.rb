module Api
  module PollSessions
    class Create < Rectify::Command
      def initialize(params)
        @params = params
      end

      def call
        poll = find_poll
        create_poll_session(poll)
      rescue => e
        return broadcast(:invalid, e.extend(::PollSessions::ErrorsRepresenter))
      end

      private

      def find_poll
        Poll.find(@params[:id])
      end

      def create_poll_session(poll)
        session = poll.poll_sessions.new
        return broadcast(:ok, session.extend(::PollSessions::CreateRepresenter)) if session.save
        broadcast(:invalid, session.errors.extend(::PollSessions::ErrorsRepresenter))
      end
    end
  end
end
