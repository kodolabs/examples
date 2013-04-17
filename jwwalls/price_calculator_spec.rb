require 'spec_helper'

describe PriceCalculator do

  let(:material)  { Factory :material, hq_cost: 5, jww_sell_price: 10 }
  let(:design)    { Factory :design, designable: product, material: material, wall_width: 3000, wall_height: 2400, units: 'mm'}
  let(:product)   { Factory :live_product } # just a stub - should be redefined later

  before do
    @calc = PriceCalculator.new
    @calc.design = design
    @calc.product = product
  end

  subject { @calc }

  context "design=" do
    before { @calc.should_receive(:width=)}
    before { @calc.should_receive(:height=)}
    before { @calc.should_receive(:material=)}
    before { @calc.design = design }
    specify { @calc.width.should == 3 }
    specify { @calc.height.should == 2.4 }
  end

  context "product=" do
    before { @calc.should_receive(:additional_cost=)}
    before { @calc.should_receive(:rights_cost_value=)}
    before { @calc.should_receive(:rights_cost_type=)}
    before { @calc.product = product }
  end

  context "material=" do
    before { @calc.should_receive(:hq_cost=)}
    before { @calc.should_receive(:jww_sell_price=)}
    before { @calc.should_receive(:packing=)}
    before { @calc.material = material }
    specify { @calc.hq_cost.should == material.hq_cost }
    specify { @calc.jww_sell_price.should == material.jww_sell_price }
    specify { @calc.packing.should == material.packing_cost }
  end

  context "#to_meters" do
    let(:product)   { Factory :live_product }

    specify "#to_metres" do
      @calc.to_metres(2, Design::METRES).should         == 2.000
      @calc.to_metres(350, Design::CENTIMETRES).should  == 3.500
      @calc.to_metres(240, Design::CENTIMETRES).should  == 2.400
      @calc.to_metres(39, Design::INCHES).should        == 0.991
      @calc.to_metres(2000, Design::MILLIMETRES).should == 2.000
    end
  end

  describe "#width_rounded" do
    before { @calc.stub(:width).and_return(1.5) }
    its(:width_rounded) { should == 2.74 }
  end

  describe "#height_rounded" do
    before { @calc.stub(:height).and_return(2.4) }
    its(:height_rounded) { should == 3.4 }
  end

  describe "#postal_tubes_cost" do
    before do
      @calc.stub(:area).and_return(20)
      @calc.stub(:postal_tubes).and_return(8)
    end
    its(:postal_tubes_cost) { should == 16 }
  end

  describe "#hq_total_cost" do
    before do
      @calc.stub(:area).and_return(5.0)
      @calc.stub(:hq_cost).and_return(10.0)
      @calc.stub(:postal_tubes_cost).and_return(12.0)
    end
    its(:hq_total_cost) { should == 62.0 }
  end

  describe "#wf_total_cost" do
    before do
      @calc.stub(:hq_total_cost).and_return(200)
      @calc.stub(:wf_value_added).and_return(30)
    end
    its(:wf_total_cost) { should == 286 }
  end

  describe "#packing_cost" do
    before do
      @calc.stub(:area).and_return(20)
      @calc.stub(:packing).and_return(8)
    end
    its(:packing_cost) { should == 16 }
  end

  describe "#base_cost" do
    before do
      @calc.stub(:area).and_return(5)
      @calc.stub(:jww_sell_price).and_return(40)
      @calc.stub(:additional_cost).and_return(20)
    end
    its(:base_cost) { should == 220.0 }
  end

  describe "#rights_cost" do
    context "percentage" do
      let(:product)         { Factory :product }
      before do
        @calc.stub(:rights_cost_type).and_return('percent')
        @calc.stub(:rights_cost_value).and_return(10)
        @calc.stub(:base_cost).and_return(80)
      end
      its(:rights_cost)     { should == 8.89 }
    end

    context "fixed" do
      let(:product)         { Factory :product }
      before do
        @calc.stub(:rights_cost_type).and_return('fixed')
        @calc.stub(:rights_cost_value).and_return(10)
      end
      its(:rights_cost)     { should == 10 }
    end
  end

  describe "#vat" do
    before do
      @calc.stub(:base_cost).and_return(41.2)
      @calc.stub(:rights_cost).and_return(30.0)
    end
    its(:vat) { should == 14.24 }
  end

  describe "#subtotal" do
    before do
      @calc.stub(:base_cost).and_return(41.2)
      @calc.stub(:rights_cost).and_return(30.0)
    end
    its(:subtotal) { should == 71.2 }
  end


  describe "total_cost" do
    context "under minimal" do
      before do
        @calc.stub(:base_cost).and_return(10)
        @calc.stub(:rights_cost).and_return(10)
        @calc.stub(:vat).and_return(10)
      end
      its(:total_cost) { should == 80.0 }
    end

    context "standard" do
      before do
        @calc.stub(:base_cost).and_return(56.7)
        @calc.stub(:rights_cost).and_return(34.8)
        @calc.stub(:vat).and_return(10.0)
      end
      its(:total_cost) { should == 101.5 }
    end
  end

  describe "order calculation" do
    context "should return price structure" do
      let(:product)         { Factory :product }
      specify { @calc.price_structure.keys.should =~ [:area, :hq_total_cost, :wf_total_cost, :packing_cost, :base_cost, :rights_cost, :vat, :vat_cost, :subtotal, :total_cost] }
    end
  end
end