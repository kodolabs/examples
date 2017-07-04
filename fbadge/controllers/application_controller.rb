class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :no_access
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  protect_from_forgery with: :exception

  helper_method :select_section, :current_company, :selected_section?, :current?

  class << self
    def select_section(name, options = {})
      before_action ->(c) { c.select_section(name) }, options
    end
  end

  def current_company
    current_user && current_user.company
  end

  def select_section(name)
    @selected_section ||= []
    @selected_section += Array(name)
  end

  def selected_section
    @selected_section || []
  end

  def selected_section?(name)
    selected_section.include?(name) || selected_section.include?(name.to_s)
  end

  def current?(name)
    :current if selected_section? name
  end

  def no_access
    render 'shared/_access_error'
  end

  def not_found
    respond_to do |format|
      format.html { render 'shared/_not_found', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end
end
