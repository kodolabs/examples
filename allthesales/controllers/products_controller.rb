class ProductsController < PublicController

  before_filter :load_for_home_page, :only => [:home]
  before_filter :set_per_page, :set_gender_search,  :only => [:index]

  after_filter :track_impression, :load_for_show_page, :only => :show
  after_filter :track_search, :save_params, :only => :index

  skip_before_filter :load_search_params, :load_additional_resources, :load_featured_categories, :only => [:click]

  cache_sweeper :category_sweeper

  has_scope :by_store
  has_scope :by_brand
  has_scope :by_category
  has_scope :by_price, :using => [:min, :max]
  has_scope :by_discount, :using => [:min, :max]
  has_scope :by_male
  has_scope :by_female
  has_scope :ordered, :default => Product::DEFAULT_ORDER
  has_scope :page, :default => 1

  def home

  end

  def index
    @products = apply_scopes(Product).search(params['by_keyword'], :with =>  { :archived => false } ).page(params[:page]).per(session[:per_page])
    @banner = Advertising.search
    @store = Store.find(params[:by_store]) unless params[:by_store].blank?
    @brand = Brand.find(params[:by_brand]) unless params[:by_brand].blank?
    @category = Category.find(params[:by_category]) unless params[:by_category].blank?
  end

  def show
    @product = Product.find_by_slug params[:id]
    raise NotFound if @product.nil?
    @related_products = @product.related_products params[:by_male], params[:by_female]
    @banner = Advertising.product
  end

  def old_route
    @product = Product.find params[:id]
    raise NotFound if @product.nil?
    redirect_to :action => :show, :id =>  @product.slug, :status => 301
  end

  def click
    respond_to do |format|
      format.js do
        @product = Product.find_by_slug params[:id]
        @product.track_click unless @product.blank? or @robot
        render :nothing => true
      end
    end
  end

protected

  def load_for_home_page
    @homepage_products = Product.homepage.limit(9)
    @slides = Slide.all
    @product_of_the_day = DayProduct.first.product rescue Product.first
    @sidebar_items = "Store"
  end

  def track_impression
    @product.track_impression unless @robot
  end

  def track_search
    Product.track_search(@products) unless @robot
  end

  def save_params
    session[:search_request_params] = request.query_parameters
    session[:search_params] = request.fullpath
  end

  def set_per_page
    session[:per_page] = params[:per_page] unless params[:per_page].blank?
    session[:per_page] ||= Product::DEFAULT_PER_PAGE
  end

  def set_gender_search
    params[:by_male] = 1 if cookies[:by_male].eql?("1")
    params[:by_female] = 1 if cookies[:by_female].eql?("1")
  end

  def load_for_show_page
    @banner = Advertising.product
    @search_params = session[:search_request_params]
  end

end
