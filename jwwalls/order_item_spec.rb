require 'spec_helper'

describe OrderItem do
  it { should belong_to :order }
  it { should belong_to :orderable }

  it { should validate_presence_of      :price }
  it { should validate_presence_of      :quantity }
  it { should validate_presence_of      :orderable_id }
  it { should validate_presence_of      :orderable_type }
  it { should validate_numericality_of  :quantity }
  it { should validate_numericality_of  :price }

  before { set_default_settings }

  context "#create_from with design in a cart" do
    let(:design)    { Factory :product_design }
    let(:cart_item) { Factory :cart_item, purchaseable: design }
    before { @order_item = OrderItem.build_from cart_item }

    specify { @order_item.quantity.should == cart_item.quantity }
    specify { @order_item.orderable.should be_a DesignOrder }
  end

  context "#create_from with accessory in a cart" do
    let(:accessory) { Factory :accessory, price: 500 }
    let(:cart_item) { Factory :cart_item, purchaseable: accessory, quantity: 1 }

    before { @order_item = OrderItem.build_from cart_item }

    specify { @order_item.quantity.should == 1 }
    specify { @order_item.orderable.should be_a Accessory }
    specify { @order_item.cost.should == accessory.subtotal }
  end

  describe "#delivery_cost" do
    before { Address.any_instance.stub(:country).and_return('GB') }
    before { DesignOrder.any_instance.stub(:pricing).and_return({area: 10})}
    before { DeliveryCalculator.any_instance.stub(:cost).and_return(99) }
    before { AccessoryDeliveryCalculator.any_instance.stub(:cost).and_return(22.5) }

    context "order item is DesignOrder" do
      before { @order = Factory :order_with_items }
      before { @order_item = @order.items.first }
      specify { @order_item.delivery_cost.should == 99 }
    end

    context "order item is accessory" do
      before { @order_item = Factory :order_item_accessory }
      before { @order = Factory :order_with_items, items: [ @order_item ] }
      specify { @order_item.delivery_cost.should == 22.5 }
    end
  end

  describe "#cost" do
    context "order item is DesignOrder" do
      before { @order_item = Factory :order_item, quantity: 2, price: 6 }
      specify do
        @order_item.cost.should == 12
      end
    end

    context "order item is accessory" do
      before { @accessory = Factory :accessory, price: 20 }
      before { @cart_item = Factory :cart_item, purchaseable: @accessory, quantity: 1 }
      before { @order_item = OrderItem.build_from(@cart_item) }
      specify { @order_item.cost.should == (20 - (20 - 20/1.2)).round(2) }
      specify { @order_item.cost_with_vat.should == @accessory.price }
    end
  end

  describe "check sub totals" do
    context "order item is DesignOrder" do
      before { @order_item = Factory :order_item }
      before { @order = Factory :order, items: [ @order_item ] }
      specify do
        @order_item.subtotal.should  == @order_item.cost + @order_item.delivery_cost
        @order_item.total_vat.should == (@order_item.subtotal * PriceCalculator.vat_rate).round(2)
      end
    end

    context "order item is accessory" do
      before { @order_item = Factory :order_item_accessory }
      before { @order = Factory :order, items: [ @order_item ] }
      before { @order_item.stub(cost: 100, vat: 20, delivery: 30) }
      specify do
        @order_item.cost_with_vat.should  == 120
        @order_item.subtotal.should       == 130
        @order_item.total_vat.should      == 26
      end
    end
  end

  describe "total cost" do
    before { @order_item = Factory :order_item_accessory }
    before { @order = Factory :order, items: [ @order_item ] }
    before { @order_item.stub(subtotal: 10, total_vat: 2) }

    specify { @order_item.total_cost.should == 12 }
  end

  describe "after add order item to order should create wall code for each one" do
    let(:site)      { sites(:nooglass) }
    let!(:cart)     { Factory :cart }
    let(:customer)  { Factory :customer }

    before do
      DeliveryCalculator.any_instance.stub(:cost).and_return(0)
      AccessoryDeliveryCalculator.any_instance.stub(:cost).and_return(0)
    end

    context 'if item is a Product' do
      before do
        @collection = Factory :collection, name: 'Jelly-S'
        @product = Factory :live_product, name: 'Dino', collection: @collection
        @design_order  = Factory :design_order, designable: @product
        @order = Factory :order_with_items, items: [ Factory(:order_item, orderable: @design_order ) ]
      end

      specify { @order.items.first.wall_code.should == "#{@order.id}/jelly-s/dino/#{@product.code}" }
    end

    context 'if item is a Custom' do
      before do
        @custom = Factory :custom
        @design_order  = Factory :design_order, designable: @custom
        @order = Factory :order_with_items, items: [ Factory.build(:order_item, orderable: @design_order ) ]
      end

      specify { @order.items.first.wall_code.should == "#{@order.id}/your-project" }
    end

    context 'if item is a Manual' do
      before do
        @manual = Factory :manual_item, name: 'Manual item'
        @order = Factory :order_with_items, items: [ Factory(:order_item, orderable: @manual ) ]
      end

      specify { @order.items.first.wall_code.should == "#{@order.id}/manual-item" }
    end

    context 'if item is an Accessory' do
      before do
        @manual = Factory :accessory, name: 'Glue'
        @order = Factory :order_with_items, items: [ Factory(:order_item, orderable: @manual ) ]
      end

      specify { @order.items.first.wall_code.should == "#{@order.id}/glue" }
    end

    context 'if item is a Test print' do
      before do
        @testprint = Factory :testprint
        @order = Factory :order_with_items, items: [ Factory(:order_item, orderable: @testprint ) ]
      end

      specify { @order.items.first.wall_code.should == "#{@order.id}/1m-x-1m-test-print" }
    end
  end

  describe "by artist" do
    before { @artist1 = Factory :artist }
    before { @artist2 = Factory :artist }
    before { @product1 = Factory :product, artist: @artist1 }
    before { @product2 = Factory :product, artist: @artist2 }
    before { @design_order1 = Factory :design_order, designable: @product1 }
    before { @design_order2 = Factory :design_order, designable: @product1 }
    before { @design_order3 = Factory :design_order, designable: @product2 }
    before { @order_item1 = Factory :order_item, orderable: @design_order1 }
    before { @order_item2 = Factory :order_item, orderable: @design_order2 }
    before { @order_item3 = Factory :order_item, orderable: @design_order3 }

    specify { OrderItem.by_artist(@artist1.id).should =~ [@order_item1, @order_item2] }
  end

  describe "by collection" do
    before { @collection1 = Factory :collection }
    before { @collection2 = Factory :collection }
    before { @product1 = Factory :product, collection: @collection1 }
    before { @product2 = Factory :product, collection: @collection2 }
    before { @design_order1 = Factory :design_order, designable: @product1 }
    before { @design_order2 = Factory :design_order, designable: @product1 }
    before { @design_order3 = Factory :design_order, designable: @product2 }
    before { @order_item1 = Factory :order_item, orderable: @design_order1 }
    before { @order_item2 = Factory :order_item, orderable: @design_order2 }
    before { @order_item3 = Factory :order_item, orderable: @design_order3 }

    specify { OrderItem.by_collection(@collection1.id).should =~ [@order_item1, @order_item2] }
  end
end
