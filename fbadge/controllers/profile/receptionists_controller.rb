class Profile::ReceptionistsController < Profile::OrganiserBaseController
  before_action :set_receptionists

  def index
    @receptionist_form = Receptionists::ReceptionistForm.new
  end

  def create
    @receptionist_form = Receptionists::ReceptionistForm.from_params params
    Receptionists::Create.call(@receptionist_form, @event) do
      on(:ok) { |event| redirect_to profile_event_receptionists_path(event), notice: 'Invite to receptionist successfully sended' }
      on(:invalid) { render :index }
    end
  end

  def destroy
    @receptionist = Receptionist.find(params[:id])
    flash = if @receptionist.destroy
      { success: 'Receptionist succesfully deleted' }
    else
      { error: 'Cannot delete receptionist' }
    end
    redirect_to profile_event_receptionists_path(@event), flash: flash
  end

  private

  def set_receptionists
    @receptionists = @event.receptionists.ordered
  end
end
