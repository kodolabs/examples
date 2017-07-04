class PollPolicy < ApplicationPolicy
  def edit?
    @record.poll_sessions.empty?
  end

  def organiser?
    return true if @record.event.profiles.as_role(:organiser).where(user_id: user.id).any?
  end
end
