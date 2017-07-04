require 'roar/json'

module PollSessions
  module CloseRepresenter
    include Roar::JSON

    property :status

    def status
      'ok'
    end
  end
end
