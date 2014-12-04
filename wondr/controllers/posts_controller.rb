class Backend::PostsController < Backend::BaseController

  def index
    @posts = Post.sorted.includes(:uploads => :students)

    respond_to do |format|
      format.json { render_for_api :default, json: @posts }
    end
  end

  def create
    @post = Post.new post_params

    respond_to do |format|
      format.json do
        if @post.save
          render_for_api :default, json: @post
        else
          render json: { errors: @post.errors }, status: 406
        end
      end
    end
  end

  def update
    @post = Post.find params[:id]

    respond_to do |format|
      format.json do
        if @post.update_attributes post_params
          render_for_api :default, json: @post
        else
          render json: { errors: @post.errors }, status: 406
        end
      end
    end
  end

  private

  def post_params
    params.require(:post).permit(:type, :name, :description, :student_ids => [], :uploads_data => [:id, :description, :student_ids => []])
  end

end
