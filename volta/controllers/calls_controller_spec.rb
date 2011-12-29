require 'spec_helper'

describe CallsController do

  before(:each) do
    @account = Factory :account
    @user = factory_object_for(@account, :user)
    @customer = factory_object_for(@account, :customer)
    @call = factory_object_for(@account, :call, :customer => @customer)

    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    response.should be_success
    response.should render_template(:index)
  end

  it "new action should render call form" do
    get :new
    response.should be_success
    response.should render_template(:new)
  end

  describe "show call" do
    before do
      (1..3).each {factory_object_for(@account, :call)}
    end
    it "should show call, rings and call history" do
      get :show, :id => @call.id

      response.should be_success
      response.should render_template(:show)
    end
  end

  describe "assign action" do
    it "should assign an call" do
      Call.stub(:assign_pending_call).and_return(@call)
      post :assign
      flash.now[:notice].should == "Call was assigned"
      response.should redirect_to(call_url(@call))
    end

    it "should not assign an call" do
      Call.stub(:assign_pending_call).and_return(nil)
      @request.env['HTTP_REFERER'] = "/calls"
      post :assign
      flash.now[:notice].should == "No pending calls"
      response.should redirect_to(@request.env['HTTP_REFERER'])
    end
  end

  describe "reschedule" do
    before  { post :reschedule, :format => :js, :id => @call.id, :schedule_at => Time.now.advance(:days => 1) }
    it      { should respond_with :success }
    specify { response.content_type.should == 'text/javascript' }
  end

end
