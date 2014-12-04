class Backend::TopicsController < Backend::BaseController

  def index
    @topics = Topic.all

    respond_to do |format|
      format.json { render_for_api :default, json: @topics }
    end
  end

end
