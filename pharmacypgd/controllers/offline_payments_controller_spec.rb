require 'spec_helper'

describe Admin::OfflinePaymentsController do
  before do
    controller.stub(:authenticate_admin!).and_return true
  end

  describe "#new" do
    before  { get :new }
    it      { should respond_with :success }
    it      { should render_template :new }
    it      { should assign_to :offline_payment }
  end

  describe "#create" do
    before do
      Factory :price, :fee => 10
      @organisation = Factory :organisation
      post :create, :offline_payment => {:reference_number => "#{@organisation.number}-#{1}", :amount => 12, :payment_method => 'cheque' }
    end

    it { should set_the_flash.to /success/i }
    it { should respond_with :redirect }
    it { should redirect_to admin_purchases_path }
  end


  describe "#create with invalid amount" do
    before do
      Factory :price, :fee => 10
      @organisation = Factory :organisation
      post :create, :offline_payment => {:reference_number => "#{@organisation.number}-#{1}", :amount => 13, :payment_method => 'cheque' }
    end

    it { should set_the_flash.to /not saved/i }
    it { should respond_with :success }
    it { should render_template :new }
  end

  describe "#create with invalid organisation number" do
    before do
      Factory :price, :fee => 10
      @assessment = Factory :valid_assessment
      @user = @assessment.user
      @pgd = @assessment.pgd
      post :create, :offline_payment => {:reference_number => "999999-#{@user.id}-#{@pgd.id}", :amount => 12, :payment_method => 'cheque' }
    end

    it { should set_the_flash.to /not saved/i }
    it { should respond_with :success }
    it { should render_template :new }
  end

  describe "#create with pharmacist ref number" do
      before do
        offline_payment = mock_model('OfflinePayment', :save => false )
        controller.stub!(:resource).and_return(offline_payment)
        post :create
      end

      it { should set_the_flash.to /not saved/i }
      it { should respond_with :success }
      it { should render_template :new }
    end

end
