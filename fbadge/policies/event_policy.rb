class EventPolicy < ApplicationPolicy
  def organiser?
    return true if @user.profiles.as_role(:organiser).where(event_id: @record.try(:id)).any?
    return true if @user.authorized_organiser?
  end
end
