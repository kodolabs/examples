class Backend::KlassesController < Backend::BaseController
  def index
    @klasses = Klass.sorted.includes(:students => :parents)

    respond_to do |format|
      format.json { render_for_api :default, json: @klasses }
    end
  end

  def create
    @klass = Klass.new klass_params

    if @klass.save
      render_for_api :default, json: @klass
    else
      render json: { errors: @klass.errors }, status: 406
    end
  end

  def update
    @klass = Klass.find params[:id]

    if @klass.update_attributes klass_params
      render_for_api :default, json: @klass
    else
      render json: { errors: @klass.errors }, status: 406
    end
  end

  def destroy
    klass = Klass.find params[:id]

    if klass.destroy
      render json: {}
    else
      render json: { errors: klass.errors}, status: 406
    end

  end

  def klass_params
    params.require(:klass).permit(:name, :year, :location, :admin_ids => [])
  end
end
