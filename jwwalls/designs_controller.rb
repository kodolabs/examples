class DesignsController < ApplicationController
  before_filter :load_and_authorize_resource, only: [:edit, :preview]
  before_filter :remember_origin_url, only: [:new, :create]
  before_filter :load_test_print, only: [:edit, :preview, :upload]

  after_filter :escape_output, only: [:upload], if: Proc.new { browser.ie? }

  def new
    @custom = Custom.new
    @design = @custom.projects.build type: 'Design'
    @design.designable = @custom
  end

  def upload
    session[:designs] ||= []
    file = params[:qqfile].is_a?(ActionDispatch::Http::UploadedFile) ? params[:qqfile] : params[:file]
    @custom = Custom.create(:image => file)
    @design = @custom.projects.build type: 'Design'
    @design.user_id = current_user.id if current_user
    if @custom.persisted? && @design.save
      session[:designs] << @design.id
      @response = @design.as_json.merge(success: true, form: render_to_string(partial: 'form'))
    else
      @response = { success: 'false' }
    end
    render :json => @response, content_type: browser.ie? ? "text/html" : "application/json"
  end

  def edit
    @design.present? ? (render action: :new) : raise(ActiveRecord::RecordNotFound)
  end

  def create
    session[:designs] ||= []
    @design = Design.new params[:design]
    @design.user_id = current_user.id if user_signed_in?
    if @design.save
      session[:designs] << @design.id
      redirect_to edit_design_path(@design, params: {test_print_option: params[:test_print_option]})
    else
      flash[:error] = 'Cannot create design'
      redirect_to :back
    end
  end

  def update
    @design = Design.find params[:id]

    @design.user = current_user if current_user.present?

    if @design.update_attributes(params[:design])
      respond_to do |format|
        format.json do
          @response = @design.as_json.merge(success: true)
          render :json => @response
        end
        format.html do
          if @design.add_to_cart == 'true'
            @cart_item = CartItem.new purchaseable_id: @design.id, purchaseable_type: @design.class.to_s
            if shopping_cart.has?(@design)
              shopping_cart.update_items
            else
              shopping_cart.cart_items << @cart_item
            end
                #@cart_item.purchaseable.blank? ||
            redirect_to cart_path
          else
            redirect_to :back
          end
        end
      end
    else
      @response = { success: false, errors: "#{@design.errors.inspect}" }
      render :json => @response, status: 500
    end
  end

  def preview
    raise(ActiveRecord::RecordNotFound) unless @design.present?
    @design.add_to_cart = true
    @start_price = @design.calculate(Material.default) if Material.default
    @height = PriceCalculator.new.to_metres @design.wall_height.to_f, @design.units
    render layout: 'design-preview'
  end

  def landing
    @design = Project.find_by_guid(params[:guid])

    raise ActiveRecord::RecordNotFound if @design.nil?

    @height = PriceCalculator.new.to_metres @design.wall_height.to_f, @design.units
    render layout: 'design-preview'
  end

  def save_to_projects
    @design = Design.find params[:id]

    if current_user.nil?
      session[:design] = @design
      render json: {}, status: 401
    else
      if @design.save_for_later(current_user)
        render json: { url: designs_path }, status: 200
      else
        render json: { errors: @design.errors.full_messages}, status: 500
      end
    end
  end

  def load_and_authorize_resource
    if current_user
      @design = current_user.projects.find params[:id]
    else
      @design = Design.find params[:id] if session[:designs].present? and session[:designs].include?(params[:id].to_i)
    end
  end

  protected

  def escape_output
    self.response.body = CGI::escapeHTML( self.response.body)
  end

  def load_test_print
    @testprint = Testprint.new
    @testprint.designable = @design.designable unless @design.blank?
  end

  def remember_origin_url
    action = params[:action]
    session[:design_origin_url] = case action
      when 'new'
        'upload'
      when 'create'
        request.referer if !request.referer.blank? && request.referer.include?(current_site.hostname)
    end
    #puts " -- action #{params.inspect}"
    #unless request.referer.blank?
    #  session[:design_origin_url] = request.referer if request.referer.include?(current_site.hostname)
    #end
  end
end
