require 'spec_helper'

describe Order do
  it { should belong_to :customer         }
  it { should have_one :delivery_address  }
  it { should have_many :items            }
  it { should have_many :adjustments      }
  it { should belong_to :site             }
  it { should belong_to :discount         }

  it { should validate_presence_of :site_id }
  it { should validate_presence_of :customer_id }

  let(:site)      { sites(:nooglass) }
  let!(:cart)     { Factory :cart }
  let(:design)    { Factory :product_design }
  let(:customer)  { Factory :customer }
  let(:accessory) { Factory :accessory }
  let(:discount)  { Factory :discount }

  context "default payment_status" do
    before        { @order = Order.create(site: site, customer: customer) }
    specify       { @order.payment_status.should == Order::PENDING }
  end

  describe "customer data" do
    before do
      @customer = Factory.build :customer
      @order = Factory.build :order, customer: @customer
    end

    specify "should be copied from customer" do
      @order.valid? # trigger before_validation callback
      @order.first_name.should    == @customer.first_name
      @order.last_name.should     == @customer.last_name
      @order.mobile_phone.should  == @customer.mobile
    end
  end

  context "#build_from" do
    before              { DeliveryCalculator.any_instance.stub(:cost).and_return(0) }
    before              { cart.cart_items << Factory(:cart_item, :purchaseable => design) }
    before              { cart.discount = discount }
    before              { @order = Order.build_from(cart, site, customer) }
    before              { @order.billing_address = Factory :address }
    before              { @order.save }

    subject             { @order }

    it                  { should be_valid               }
    its(:total)         { should == cart.total_with_vat }
    its(:discount)      { should == cart.discount       }
    its(:size)          { should == cart.size           }
    its(:installation)  { should == cart.installation   }
  end

  context "build order containing design, accessory product and test print" do

    let(:testprint) { Factory :testprint }

    before do
      DeliveryCalculator.any_instance.stub(:cost).and_return(0)
      AccessoryDeliveryCalculator.any_instance.stub(:cost).and_return(0)
    end

    before do
      cart.cart_items << Factory(:cart_item, purchaseable: design )
      cart.cart_items << Factory(:cart_item, purchaseable: accessory )
      cart.cart_items << Factory(:cart_item, purchaseable: testprint )

      @order = Order.build_from(cart, site, customer)
      @order.billing_address = Factory :address
      @order.save
    end

    subject     { @order }
    it          { should be_valid }
    its(:size)  { should == 3 }
    specify     { @order.total.to_f.should == cart.total_with_vat.to_f }
  end

  describe "#by_site" do
    let(:site2) { sites(:jwwalls) }
    before      { @order1 = Factory :order, site: site }
    before      { @order2 = Factory :order, site: site2 }
    specify     { Order.by_site(site.id).should == [ @order1 ] }
  end

  describe "#by_payment_status" do
    before      { @order1 = Factory :order, payment_status: 'pending' }
    before      { @order2 = Factory :order, payment_status: 'paid' }
    specify     { Order.by_payment_status('pending').should == [ @order1 ] }
  end

  describe "#payment" do
    let(:xpay_payment) { mock }

    before do
      @order = Factory.build :order_for_payment
      @order.stub(:xpay_payment).and_return(xpay_payment)
    end

    context "successful payment" do
      before  do
        xpay_payment.should_receive(:make_payment).and_return(1)
        xpay_payment.should_receive(:response_block).and_return( { error_code: nil, transaction_reference: 'ALZ-737373' } )
      end

      specify       { expect {@order.payment}.to change(@order, :payment_status).to(Order::PAID) }
      specify       { expect {@order.payment}.to change(Transaction, :count).by(1) }
      specify do
        @order.payment.should == true
        @order.persisted?.should == true
      end

      specify 'should send confirmation email' do
        expect{ @order.payment }.to change(ActionMailer::Base.deliveries, :size).by(2)
      end
    end

    context "declined" do
      before do
        xpay_payment.should_receive(:make_payment).and_return(2)
        xpay_payment.should_receive(:response_block).and_return({:error_code => 'declined message'})
      end

      specify { expect {@order.payment}.to_not change(@order, :payment_status).to(Order::PAID) }
      specify do
        @order.payment.should == false
        @order.payment_status.should == Order::PENDING
        @order.persisted?.should == false
        @order.should have(1).error
        @order.errors[:base].should == ['declined message']
      end
    end

    context 'problems with saving transaction' do
      before { Transaction.any_instance.stub(:save).and_return(false) }
      before { Transaction.any_instance.stub(:errors).and_return({base: 'Error of errors'}) }
      before { xpay_payment.should_receive(:make_payment).and_return(1) }
      before { xpay_payment.should_receive(:response_block).and_return( { error_code: nil, transaction_reference: 'ALZ-737373' } ) }
      specify "should have errors" do
        @order.payment.should == false
        @order.payment_status.should == Order::PENDING
        @order.persisted?.should == false
        @order.should have(1).error
      end
    end
  end

  describe "#set_delivery_cost" do
    before { @order = Factory.build :order }
    before { OrderItem.any_instance.stub(:delivery_cost).and_return(5) }

    context "with items" do
      before { PriceCalculator.stub(:vat_rate).and_return(0.2) }
      before { @order_item1 = Factory :order_item }
      before { @order_item2 = Factory :order_item_accessory }
      before { @order.items = [ @order_item1, @order_item2 ] }

      context 'delivery with discount' do
        context 'discount should be applied(>=150)' do
          before { OrderItem.any_instance.stub(:cost).and_return(70) }
          specify {
            @order.save!
            @order.delivery_cost.round(2).should == 0
          }
        end

        context 'sum is not enought to get free delivery' do
          before { OrderItem.any_instance.stub(:cost).and_return(35) }
          specify {
            @order.save!
            @order.delivery_cost.round(2).should == 10
          }
        end
      end
    end

    specify "with no items" do
      @order.save!
      @order.delivery_cost.should == 0
    end
  end

  describe "totals" do
    before { @order = Factory.build :order }
    before { @order.items = [Factory(:order_item, price: 40), Factory(:order_item, price: 40)] }
    before { OrderItem.any_instance.stub(:delivery_cost).and_return(10) }
    before { @order.save }

    specify { @order.total.to_f.should == 120.0 }
  end

  describe "discount" do
    before { @discount = Factory :discount, code: 'X9', value: 10, value_type: 'amount' }
    before { @order = Factory :order_with_items }

    specify do
      total = @order.total
      @order.discount = @discount
      @order.save
      @order.total.should == total - (10 * 1.2)
    end
  end

  describe "after delete from order should create adjustment" do
    before { @order = Factory.build :order, payment_status: 'paid' }
    before { @order.items = [Factory(:order_item, price: 40), Factory(:order_item, price: 40)] }
    before { OrderItem.any_instance.stub(:delivery_cost).and_return(0) }
    before { @order.save }
    specify { @order.total.to_f.should == 96.0 }
    specify "after delete" do
      @order.items.first.destroy
      @order.reload.total.to_f.should == 48.0
      Adjustment.count.should == 1
      Adjustment.last.amount.to_f.should == -48.0
    end
  end

  describe "#create job" do
    before { @order = Factory :order, status: 'new', payment_status: 'paid' }

    specify "should create job and change status to production" do
      @order.production!
      @order.reload
      @order.status.should == 'production'
      @order.job.should_not be_nil
    end

    specify "should send email to factory" do
      expect{ @order.production! }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

  end

  describe "cancel job" do
    before { @order = Factory :order_with_items, status: 'production', payment_status: 'paid', job: Factory(:job) }

    context do
      pending do
        @order.cancel!
        # should change statuses
        @order.payment_status.should == 'refund'
        @order.status.should == 'canceled'

        # should destroy job
        @order.job.should be_nil

        @order.adjustments.reload

        puts " -- order #{@order.id}"
        puts " -- adjustments #{@order.adjustments}"
        puts " -- adjustments 2 #{Adjustment.all}"

        # should create adjustment
        @order.should have(1).adjustments
      end
    end

    context 'if order not paid yet, adjustment should not be created' do
      before { @order = Factory :order, status: 'production', payment_status: 'pending', job: Factory(:job) }
      before { @order.cancel }
      specify { @order.should have(0).adjustments }
    end

    context 'should send email' do
      specify { expect{ @order.cancel }.to change(ActionMailer::Base.deliveries, :size).by(1) }
    end
  end

  describe "calc_expected_delivery_date" do
    before { Settings.average_production_time = 1 }
    before { Time.stub(:now).and_return("23/02/2012 9:00:00".to_time) }

    context 'simple business day' do
      before { Order.any_instance.stub(:delivery_region).and_return('UK') }
      before { @order = Factory :order }

      specify { @order.delivery_date.should == "27/02/2012".to_date }
    end

    context 'when sat and sun' do
      before { Order.any_instance.stub(:delivery_region).and_return('EU') }
      before { @order = Factory :order }

      specify { @order.delivery_date.to_date.should == "28/02/2012".to_date}
    end
  end

  describe "#fields_for_customer" do
    specify do
      order = Factory.create :order
      order.fields_for_customer.should == { fullname: order.fullname, firstname: order.first_name, lastname: order.last_name,
                                            city: order.city, email: order.email, phone: order.phone, street: order.street,
                                            stateprovince: order.county, postcode: order.postal_code, countrycode: order.country }
    end
  end

  describe "sale_amount" do
    before do
      @order = Factory.build :order
      @order.stub(:subtotal).and_return(60)
      @order.stub(:delivery_cost).and_return(5.5)
    end

    specify "should return subtotal without delivery" do
      @order.sale_amount.should == 54.5
    end
  end

  describe "order_info" do
    before do
      @order = Factory.create :order
      @pepsi_design = Factory.create :design_order, designable: Factory.create(:product, name: 'Pepsi')
      @cola_design = Factory.create :design_order, designable: Factory.create(:product, name: 'Cola')
      @order.items << Factory.create(:order_item, orderable: @pepsi_design)
      @order.items << Factory.create(:order_item, orderable: @cola_design)
    end

    specify "should contain product titles" do
      @order.order_info.should == 'Pepsi, Cola'
    end
  end
end
