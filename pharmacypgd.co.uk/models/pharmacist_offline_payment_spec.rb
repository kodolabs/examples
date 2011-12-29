require 'spec_helper'

describe PharmacistOfflinePayment do
  before(:each) do
    @price = Factory :price
    @organisation = Factory :organisation
    @user = pharmacist_factory
    @pgd = Factory :pgd
    @credits = 1

    Factory :valid_assessment, :user => @user, :pgd => @pgd

    @ref_num = "#{@organisation.number}-#{@user.id}-#{@pgd.id}"
  end

  describe "reference_number validation" do
    it "should validate when organisation/pharmacist/pgd supplied" do
      PharmacistOfflinePayment::match(@ref_num).should be_true
      @offline_payment = PharmacistOfflinePayment.new :reference_number => @ref_num #, :total_amount_confirmation => (@fee * 1.2)
      @offline_payment.should have(:no).errors_on(:reference_number)
    end

    it "should not validate when invalid organisation/pharmacist/pgd supplied" do
      ref_num = '12341234-1231231-55314'
      PharmacistOfflinePayment::match(ref_num).should be_true
      @offline_payment = PharmacistOfflinePayment.create :reference_number => ref_num #, :total_amount_confirmation => (@fee * 1.2)
      @offline_payment.should have(3).errors_on(:reference_number)
    end
  end

  describe "process offline payment from pharmacist" do
    before do
      @amount = Price.fee_for(@credits) * 1.2 #VAT
    end

    it "should not validate provided with invalid reference number" do
      @ref_num = '9990-999-999'
      payment = PharmacistOfflinePayment.new :reference_number => @ref_num, :payment_method => 'cheque', :amount => @amount, :purchased_at => Date.today

      payment.valid?.should be_false
    end

    it "should not validate provided with invalid amount" do
      payment = PharmacistOfflinePayment.new :reference_number => @ref_num, :payment_method => 'cheque', :amount => 9999, :purchased_at => Date.today

      payment.valid?.should be_true
      payment.save.should be_false
      payment.errors[:"purchase.total_amount"].should_not be_nil
    end

    it "should create purchase based on reference number" do
      offline_payment = PharmacistOfflinePayment.new :reference_number => @ref_num, :payment_method => 'cheque', :amount => @amount, :purchased_at => Date.today

      offline_payment.valid?.should be_true
      offline_payment.save.should be_true

      payment = Payment.last
      payment.should_not be_nil
      payment.user.should == @user
      payment.organisation.should == @organisation
      payment.pgd.should == @pgd
      payment.credit_used?.should be_false

      purchase = payment.purchase
      purchase.should_not be_nil
      purchase.purchaser.should == @user
      purchase.credits.should == @credits

    end
  end
end