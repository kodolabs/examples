class Backend::ParentsController < Backend::BaseController

  def index
    @parents = Parent.sorted
    render_for_api :default, json: @parents
  end

  def create
    @parent = Parent.new parent_params

    respond_to do |format|
      format.json do
        if @parent.invite!
          render_for_api :default, json: @parent
        else
          render json: { errors: @parent.errors }, status: 406
        end
      end
    end
  end

  def update
    @parent = Parent.find params[:id]

    respond_to do |format|
      format.json do
        if @parent.update_attributes parent_params
          render_for_api :default, json: @parent
        else
          render json: { errors: @parent.errors }, status: 406
        end
      end
    end
  end

  def destroy
    @parent = Parent.find params[:id]

    if @parent.destroy
      render json: {}
    else
      render json: { errors: @parent.errors}, status: 406
    end
  end


  def parent_params
    params.require(:parent).permit(:first_name, :last_name, :email)
  end

end
