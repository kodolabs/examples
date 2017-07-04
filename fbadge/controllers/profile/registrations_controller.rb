class Profile::RegistrationsController < Profile::OrganiserBaseController
  before_action :find_registration, only: [:cancel]

  def index
    @registrations = @event.registrations.ordered
  end

  def cancel
    flash = if @registration.update(is_canceled: true, badge: nil)
      { success: 'Registration successfully canceled' }
    else
      { error: 'Can not cancel registration' }
    end
    redirect_to profile_event_registrations_path(@event), flash: flash
  end

  private

  def find_registration
    @registration = @event.registrations.find(params[:registration_id])
  end
end
