require 'spec_helper'

describe ProductsController do

  describe 'visit home' do
    before do
      @second_brand = Factory :brand, :name => "second"
      @first_brand = Factory :brand, :name => "first"
      @second_store = Factory :store, :name => "second"
      @first_store = Factory :store, :name => "first"
      Factory :product, :brand => @first_brand, :store => @first_store
      Factory :product, :brand => @second_brand, :store => @second_store
      get :home
    end
    it { should respond_with :success }
    it { should render_template :home }
    it { should assign_to(:homepage_products) }
    it { should assign_to(:product_of_the_day) }
    it { should assign_to(:slides) }
    it { should assign_to(:stores) }
    it { should assign_to(:brands) }
    specify { assigns(:stores).should == [@first_store, @second_store] }
    specify { assigns(:brands).should == [@first_brand, @second_brand] }
  end

  describe 'visit index' do
    before  { Factory :product; get :index }
    it { should respond_with :success }
    it { should render_template :index }
    it { should assign_to(:products) }
    it { session[:search_request_params].should_not be_nil }
    it { session[:search_params].should_not be_nil }
    it { session[:search_request_params].should == request.query_parameters }
    it { session[:search_params].should == request.fullpath }
  end

  describe 'get show product' do
    before do
      @product = Factory :product
      get :show, :id => @product.slug
    end
    it { should respond_with :success }
    it { should render_template :show }
    it { should assign_to(:product) }
    it { should assign_to(:related_products) }
  end


  describe 'get product by id' do
    before { @product = Factory :product; get :old_route, :id => @product.id}
    it { should respond_with :redirect }
    specify { response.code.should == "301" }
  end

  describe "get wrong product" do
    before do
      @product = Factory :product
      get :show, :id => "whore_sale"
    end
    it { should respond_with :not_found }
    it { should render_template 'errors/error404' }
  end


  describe "should not search archived product" do
    before { @product = Factory :product, :archived => true }
    before { ThinkingSphinx::Test.index            }
    before { get :index, :keyword => @product.name }

    it { should assign_to :products }
    specify { assigns(:products).should == [] }
  end

  describe "should parse by_slug param" do
    before do
      @relevant_store = Factory :store
      @relevant_product = Factory(:product, :store => @relevant_store)
      sleep(1)
      @other_store = Factory :store
      @other_products = FactoryGirl.create_list(:product, 2, :store => @other_store )
      @relevant_product_2 = Factory(:product, :store => @relevant_store)
     end
    before { ThinkingSphinx::Test.index }
    before { get :index, :by_slug => @relevant_store.slugg.name }

    it { should respond_with :success }
    it { should assign_to :products }
    it { assigns(:products).should == [@relevant_product_2, @relevant_product] }
  end

end
