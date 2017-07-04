class Profile::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event, only: [:edit, :update]
  before_action :set_profile, only: [:edit]

  select_section :events, only: [:edit]

  def edit
    @profile_form = Profiles::ProfileForm.new(@profile.attributes)
  end

  def update
    @profile_form = Profiles::ProfileForm.from_params params
    Profiles::Update.call(@profile_form, @event) do
      on(:ok) { |event| redirect_to edit_profile_event_profile_path(event), notice: 'Profile successfully updated' }
      on(:invalid) { |event| redirect_to edit_profile_event_profile_path(event), flash: { error: 'Error: Profile not updated' } }
      on(:invalid_form) { render :edit }
    end
  end

  private

  def find_event
    @event = current_user.events.find(params[:event_id])
  end

  def set_profile
    @profile = @event.profiles.where(user: current_user).first
  end
end
