class Profile::OrganiserBaseController < ApplicationController
  before_action :authenticate_user!
  before_action :find_event, :select_section_events

  def find_event
    @event = current_user.events.find(params[:event_id])
    authorize @event, :organiser?
  end

  def select_section_events
    select_section :events
  end
end
