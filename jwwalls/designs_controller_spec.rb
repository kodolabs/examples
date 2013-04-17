require 'spec_helper'

describe DesignsController do

  let(:custom)          { Factory :custom }
  let(:design)          { Factory :product_design }
  let(:material)        { Factory :material }
  let(:user)            { Factory :user }
  let(:user_design)     { Factory :product_design, user: user }

  before { set_current_site Site.first }

  describe "#save_to_projects" do
    context "authorized" do
      before { sign_in user }

      context "everything is ok" do
        before { @design = Factory :product_design }
        before { post :save_to_projects, id: @design.id }
        it { should respond_with :success }
        it { ActiveSupport::JSON.decode(response.body)['url'].should_not be_nil }
      end

      context "something is wrong" do
        before { @design = Factory :product_design  }
        before { Design.should_receive(:find).and_return(@design) }
        before { Design.any_instance.stub(:save!).and_return(false) }
        before { post :save_to_projects, id: @design.id }
        it { should respond_with 500 }
      end
    end

    context "non authorized" do
      before { @design = Factory :product_design }
      before { post :save_to_projects, id: @design.id }
      it { should respond_with 401 }
    end
  end

  describe "#new" do
    before  { get :new }
    it      { assigns[:design].should be_a Design }
  end

  describe "#edit" do
    context "user logged in" do
      before  { sign_in user }
      before  { get :edit, :id => user_design.id }
      it      { assigns[:design].should == user_design }
      it      { should render_template :new }
    end

    context "user logged in and access stranger design" do
      before  { sign_in user }
      before  { get :edit, :id => design.id }
      it      { assigns[:design].should == nil }
      it      { should respond_with :not_found }
    end

    context "user doesn't logged in" do
      before  { session[:designs] = [design.id] }
      before  { get :edit, :id => design.id }
      it      { assigns[:design].should == design }
      it      { should render_template :new }
    end

    context "user doesn't logged in and access stranger design" do
      before  { session[:designs] = [] }
      before  { get :edit, :id => design.id }
      it      { assigns[:design].should == nil }
      it      { should respond_with :not_found }
    end
  end

  describe "#update" do
    before do
      @design = mock_model(Design)
      @design.stub(:add_to_cart).and_return('false')
      Design.should_receive(:find).and_return(@design)
    end

    context "success" do
      before  { @design.stub(:update_attributes).and_return(true) }
      before  { @design.stub(:as_json).and_return({}) }
      before  { post :update, id: 1, format: :json }
      it      { assigns[:design] }
      it      { should respond_with :success }
      it      { should respond_with_content_type :json }
    end

    context "failure" do
      before  { @design.stub(:update_attributes).and_return(false) }
      before  { post :update, :id => 1, format: :json }
      it      { assigns[:design] }
      it      { should respond_with :error }
    end
  end

  describe "add_to_cart - check material" do
    before { request.env["HTTP_REFERER"] = '/back' }
    before { @design = Factory :product_design, material: nil }
    before { @material = Factory :material }

    context 'with material' do
      before { put :update, id: @design.id, design: { add_to_cart: 'true', material_id: @material.id } }
      it { should redirect_to cart_path }
    end

    context 'w/o material' do
      before { put :update, id: @design.id, design: { add_to_cart: true } }
      it { should respond_with 500 }
    end
  end

  pending "#upload"

  describe "GET preview" do
    context "can access" do
      before do
        Material.stub(:default).and_return(true)
        @design = double 'Design'
        @design.should_receive(:add_to_cart=)
        @design.stub(:id).and_return(1)
        session[:designs] = [1]

        Design.should_receive(:find).and_return(@design)
        @design.should_receive(:calculate).and_return(100)
        @design.stub(:wall_height).and_return(2)
        @design.stub(:wall_width).and_return(2)
        @design.stub(:units).and_return("metres")
        @design.stub(:designable)
      end
      specify do
        get :preview, id: 1

        assigns[:design]
        should render_template :preview
        should render_with_layout 'design-preview'
      end
    end
    context "can not access" do
      before do
        session[:designs] = []
      end
      specify do
        get :preview, id: design.id
        should respond_with :not_found
      end
    end
  end
end