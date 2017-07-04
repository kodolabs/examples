class ActionSequence
  attr_reader :success, :details, :actions

  def initialize(actions)
    @success = true
    @actions = actions
  end

  def perform
    actions.each do |method|
      return [false, details] unless success

      send(method)
    end

    [success, '']
  rescue => e
    Rollbar.error e
    [false, e.message]
  end
end
