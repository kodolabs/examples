require 'spec_helper'

describe RingsController do

  before(:each) do
    @account  = factory_account
    @user     = factory_object_for(@account, :user)
    @call    = factory_object_for(@account, :call)

    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    response.should be_success
    response.should render_template(:index)
    assigns(:rings).should == []
  end

  it "create action should create new call for given call" do
    CallHandler.stub(:dial).and_return(true)
    request.env["HTTP_REFERER"] = "/referer"
    post :create, :call_id => @call.id, :format => :json
    response.should be_success
    response.content_type.should == 'application/json'
    assigns[:ring].should_not == nil
  end
end
