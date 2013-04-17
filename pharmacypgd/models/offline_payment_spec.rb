require 'spec_helper'

describe OfflinePayment do
  before(:each) do
    @price = Factory :price
    @organisation = Factory :organisation
    @user = pharmacist_factory
    @credits = 5
  end

  describe "reference_number validation" do
    it "should error out when invalid format is supplied" do
      ref_num = "aaa-bbb"
      OfflinePayment::match(ref_num).should be_false
      @offline_payment = OfflinePayment.new :reference_number => ref_num
      @offline_payment.should have(1).errors_on(:reference_number)
    end

    it "should validate when organisation/credits supplied" do
      ref_num = "#{@organisation.number}-#{@credits}"
      OfflinePayment::match(ref_num).should be_true
      @offline_payment = OfflinePayment.new :reference_number => ref_num #, :total_amount_confirmation => (@fee * 5 * 1.2)
      @offline_payment.should have(:no).errors_on(:reference_number)
    end
  end

  describe "process offline payment from organisation" do
    before do
      @ref_num = "#{@organisation.number}-#{@credits}"
      @amount = Price.fee_for(@credits) * @credits * 1.2 #VAT
    end

    it "should create purchase based on reference number" do
      payment = OfflinePayment.new :reference_number => @ref_num, :payment_method => 'cheque', :amount => @amount, :purchased_at => Date.today

      payment.valid?.should be_true
      payment.save.should be_true

      purchase = Purchase.last
      purchase.should_not be_nil
      purchase.purchaser.should == @organisation
      purchase.credits.should == @credits

    end
  end
end