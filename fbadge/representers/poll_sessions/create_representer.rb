require 'roar/json'

module PollSessions
  module CreateRepresenter
    include Roar::JSON

    property :status
    property :id, as: :poll_session_id

    def status
      'ok'
    end
  end
end
