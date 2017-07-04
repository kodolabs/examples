module RequestServices
  class Build
    def initialize(params)
      @params = params
    end

    def call
      @request = Request.new @params
      check_body
      @request
    end

    private

    def check_body
      return if @request.body_top.blank? && @request.body_bottom.blank?
      @request.body = render('feedback_request_emails/reguest_body', request: @request)
    end

    def render(partial, assigns = {})
      view = ActionView::Base.new(ActionController::Base.view_paths, assigns)
      view.extend ApplicationHelper
      view.render(partial: partial)
    end
  end
end
