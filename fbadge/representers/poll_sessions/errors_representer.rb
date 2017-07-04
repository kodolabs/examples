require 'roar/json'

module PollSessions
  module ErrorsRepresenter
    include Roar::JSON

    property :status
    property :error_message

    def status
      'error'
    end

    def error_message
      return 'Poll Session not active' if is_a?(Exception)
      return full_messages if full_messages.count > 1
      full_messages.first
    end
  end
end
