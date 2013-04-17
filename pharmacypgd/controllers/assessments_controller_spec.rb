require 'spec_helper'

describe Pharmacist::AssessmentsController do
  before do
    @user = Factory :user
    sign_in @user
  end

  describe "attempt to create new assessment with no PGD specified" do
    before do
      post :create
    end

    it "should redirect to PGDs page" do
      should redirect_to pharmacist_pgds_path
    end
  end

  describe "create new assessment" do
    before do
      @pgd = Factory :pgd
      post :create, :pgd_id => @pgd.id
    end

    it "should redirect to assessment page" do
      should assign_to :assessment
      should redirect_to pharmacist_assessment_path(assigns[:assessment])
    end
  end

  describe "show assessment page" do
    before do
      @pgd = Factory :pgd
      @questions = []
      (1..3).each do
        @questions << Factory(:question, :pgd => @pgd)
      end
      @assessment = Factory :assessment, :user => @user, :pgd => @pgd
      get :show, :id => @assessment.id
    end

    it "should assign assessment, respond with success and render show template" do
      should respond_with :success
      should render_template :show
      should assign_to :assessment
    end

    describe "should process answers" do
      before do
        post :answer, :id => @assessment.id, :answer => { :question_id => @questions[0].id, :choice => 'yes'}, :format => :json
      end

      it "should respond with json" do
        should respond_with :success
        response.content_type.should == 'application/json'        
      end
    end
  end

  describe "assessment completed page with invalid assessment status" do
    before do
      @assessment = Factory :assessment, :user => @user
      get :complete, :id => @assessment.id
    end

    it "should respond with success" do
      should respond_with :redirect
    end
  end

  describe "assessment completed page" do
    before do
      @assessment = Factory :assessment, :user => @user
      @assessment.update_attributes(:status => 'complete')
      get :complete, :id => @assessment.id
    end

    it "should respond with success" do
      should respond_with :success
      should render_template :complete
      should assign_to :assessment
    end
  end

end
