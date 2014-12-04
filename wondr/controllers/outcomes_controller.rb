class Backend::OutcomesController < Backend::BaseController

  def index
    @outcomes = Outcome.roots

    respond_to do |format|
      format.json { render_for_api :default, json: @outcomes }
    end
  end

end
