class Backend::AdminsController < Backend::BaseController
  def index
    @teachers = Admin.sorted
    render_for_api :default, json: @teachers
  end

  def create
    @admin = Admin.new admin_params

    respond_to do |format|
      format.json do
        if @admin.save
          render_for_api :default, json: @admin
        else
          render json: { errors: @admin.errors }, status: 406
        end
      end
    end
  end

  def update
    @admin = Admin.find params[:id]

    respond_to do |format|
      format.json do
        if @admin.update_attributes admin_params
          render_for_api :default, json: @admin
        else
          render json: { errors: @admin.errors }, status: 406
        end
      end
    end
  end

  def destroy
    admin = Admin.find params[:id]

    if admin.destroy
      render json: {}
    else
      render json: { errors: admin.errors}, status: 406
    end

  end

  def admin_params
    params.require(:admin).permit(:first_name, :last_name, :email)
  end
end
