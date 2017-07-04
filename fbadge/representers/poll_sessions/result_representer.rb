require 'roar/json'

module PollSessions
  module ResultRepresenter
    include Roar::JSON

    property :poll_id
    property :id, as: :poll_session_id
    property :question
    property :answers

    delegate :question, to: :poll

    def answers
      ps_answers = {}
      poll.answers.each do |answer|
        ps_answers[answer.value] = answer.votes.by_poll_session(self).count
      end
      ps_answers
    end
  end
end
