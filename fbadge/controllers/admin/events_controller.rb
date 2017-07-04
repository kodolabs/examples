class Admin::EventsController < Admin::BaseController
  helper_method :sort_column, :sort_direction

  select_section :events

  def index
    @collection = Event.order(
      sort_column + ' ' + sort_direction
    ).page(params[:page])
  end

  private

  def sort_column
    Event.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
