class Profile::EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event, only: [:show, :edit, :update, :destroy]

  select_section :events, only: [:index, :show, :edit]

  def index
    @visited = current_user.events.merge(Profile.as_role(:visitor))
    @organised = current_user.events.merge(Profile.as_role(:organiser))
  end

  def new
    authorize Event, :organiser?
    select_section :create_event
    @event = Event.new
    @event.agendas.build
  end

  def edit
    authorize @event, :organiser?
  end

  def create
    authorize Event, :organiser?
    @event = Event.new(event_params.merge(creator: current_user))
    if @event.save
      Events::CreateData.call(@event, current_user)
      redirect_to profile_event_path(@event), notice: 'Event successfully created'
    else
      render :new
    end
  end

  def update
    authorize @event, :organiser?
    if @event.update(event_params)
      Registrations::UpdateStatus.call(@event)
      redirect_to profile_event_path(@event), notice: 'Event successfully updated'
    else
      render :edit
    end
  end

  def destroy
    authorize @event, :organiser?
    flash = if @event.destroy
      { success: 'Event successfully deleted' }
    else
      { error: 'Cannot delete event' }
    end
    redirect_to profile_events_path, flash: flash
  end

  def sync
    authorize Event, :organiser?
    Events::Sync.call(current_user, params['event_id']) do
      on(:ok) { redirect_to profile_events_path, notice: 'Trying to sync event' }
    end
  end

  private

  def find_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :name, :description, :begins_on,
      :ends_on, :status, :is_published,
      :logo, :tag_ids,
      agendas_attributes: %i(id date begins_at ends_at title description speaker location _destroy)
    )
  end
end
