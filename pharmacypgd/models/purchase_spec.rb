require 'spec_helper'

describe Purchase do

  before(:each) do
    @fee = 10
    @price = Factory :price, :fee => @fee
  end

  it {
    should belong_to :purchaser

    should validate_presence_of     :credits
    should validate_numericality_of :credits
    should validate_presence_of     :payment_method
  }



  describe "order amount" do
    before(:each) do
      @discount = 10.0
      @credits = 5
      @vat = AppConfig['vat'].to_f
      @organisation = Factory :organisation
      @purchase = Factory :purchase, :purchaser => @organisation
    end

    it "should calculate due amount with discount" do
      @organisation.update_attribute(:discount, @discount)
      @organisation.reload

      @purchase.credits = 0
      @purchase.calculate_order_amount.should == 0

      @purchase.credits = @credits
      @purchase.calculate_order_amount.to_f.should == (@fee * @credits) * (1 - @discount / 100.0) * (1 + @vat / 100.0)
    end

    it "should calculate due amount with zero discount" do
      @organisation.update_attribute(:discount, 0)
      @organisation.reload

      @purchase.credits = 0
      @purchase.calculate_order_amount.should == 0

      @purchase.credits = @credits
      @purchase.calculate_order_amount.should == (@fee * @credits) * (1 + @vat / 100.0)
    end
  end

  describe "it should adjust credits for purchaser" do
    before do
      @credits = 7
      @organisation = Factory :organisation
      @purchase = Factory.build(:purchase, :purchaser => @organisation)
    end

    it "should add credits on create" do
      credits_before = @organisation.credits

      @purchase.credits = @credits
      @purchase.save

      @organisation.reload
      @organisation.credits.should == @credits + credits_before

      @purchase.destroy

      @organisation.reload
      @organisation.credits.should == credits_before
    end
  end

  describe ".vat_amount" do
    before do
      @vat = AppConfig['vat'].to_f
      @amount = 100
      @discount = 10
      @purchase = Factory.build :purchase, :purchaser => Factory(:organisation, :discount => @discount)
      @purchase.amount = @amount
    end
    subject {@purchase.vat_amount}
    it {should == ((@amount - @discount) / 100.0) * @vat}
  end

  describe ".discount_amount" do
    before do
      @amount = 100
      @discount = 10
      @purchase = Factory.build :purchase, :purchaser => Factory(:organisation, :discount => @discount)
      @purchase.amount = @amount
    end
    subject {@purchase.discount_amount}
    it {should == (@amount / 100.0) * @discount}
    it "should be negative if needed" do
      @purchase.discount_amount(true).should == -1 * (@amount / 100.0) * @discount
    end
  end
end
