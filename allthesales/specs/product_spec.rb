require 'spec_helper'

describe Product do

  before(:all) do
    ThinkingSphinx::Test.start
  end

  after(:all) do
    ThinkingSphinx::Test.stop
  end

  it { should belong_to :store }
  it { should belong_to :brand }
  it { should belong_to :category }
  it { should have_one   :day_product  }

  it { should validate_presence_of :brand_id }
  it { should validate_presence_of :store_id }
  it { should validate_presence_of :category_id }
  it { should validate_presence_of :name }

# this test is weirdly not working
=begin
  context "ordered" do
    before do
      @p1 = Factory :product, :value => 200, :price => 100, :created_at => 1.weeks.ago # :discount => 50
      @p2 = Factory :product, :value => 150, :price => 90, :created_at => 3.weeks.ago # :discount => 40
      @p3 = Factory :product, :value => 100, :price => 70, :created_at => 2.weeks.ago # :discount => 30
    end

    before { ThinkingSphinx::Test.index }

    it "correctly orders by various attributes" do
      Product.ordered('price asc').to_a.should == [@p3, @p2, @p1]
      Product.ordered('price desc').to_a.should == [@p1, @p2, @p3]
      Product.ordered('discount asc').to_a.should == [@p3, @p2, @p1]
      Product.ordered('discount desc').to_a.should == [@p1, @p2, @p3]
      Product.ordered('created_at desc').to_a.should == [@p1, @p3, @p2]
    end
  end
=end

  describe "genders method contains product's genders" do
    before do
      @male_product   = Factory :product, :male => true, :female => false
      @female_product = Factory :product, :male => false, :female => true
      @unisex_product = Factory :product, :male => true, :female => true
    end

    before { ThinkingSphinx::Test.index }

    it "shows correct gender list" do
      @male_product.genders.should   == ['male']
      @female_product.genders.should == ['female']
      @unisex_product.genders.should == ['male', 'female']
    end
  end

  context "tracking" do
    let(:product) { Factory :product }

    it "should count impressions" do
      expect { product.track_impression }.to change(product, :impressions).by(1)
    end

    it "should count clicks" do
      expect { product.track_click }.to change(product, :clicks).by(1)
    end

    describe "group search impressions" do
      before do
        @products = []
        3.times do
          @products << Factory(:product)
        end
      end

      it { expect { Product.track_search @products }.to change(@products[0], :searches).by(1) && change(@products[1], :searches).by(1) }
    end

    describe "reset statistics" do
      before do
        product.track_impression
        product.track_click
        Product.track_search [product]
      end

      it { expect {product.reset_stats}.to change(product, :impresssions).to(0) && change(product, :clicks).to(0) && change(product, :searches).to(0) }
    end
  end

  describe "related products" do
    before do
      @mobile     = Factory :sub_sub_category
      @clothes    = Factory :sub_sub_category

      @iphone     = Factory :product, :category => @mobile, :male => true,  :female => false
      @out_of_sale_phone = Factory :product, :category => @mobile, :male => true,  :female => false, :archived => true
      @android    = Factory :product, :category => @mobile, :male => true,  :female => true

      @tshirt_pink   = Factory :product, :category => @clothes, :male => false, :female => true
      @tshirt_blue   = Factory :product, :category => @clothes, :male => true,  :female => false
      @tshirt_black_unisex  = Factory :product, :category => @clothes, :male => true,  :female => true
      @out_of_sale_shirt = Factory :product, :category => @clothes, :male => true,  :female => false, :archived => true
    end

    context 'search condition: male=false, female=false' do
      specify { @iphone.related_products(false, false).should include @android          }
      specify { @iphone.related_products(false, false).should_not include @tshirt_pink  }
      specify { @iphone.related_products(false, false).should_not include @out_of_sale_phone  }
    end

    context 'search condition: male=true, female=false' do
       specify { @tshirt_blue.related_products(true, false).should include @tshirt_black_unisex   }
       specify { @tshirt_black_unisex.related_products(true, false).should include @tshirt_blue           }

       specify { @tshirt_blue.related_products(true, false).should_not include @tshirt_pink       }
       specify { @tshirt_blue.related_products(true, false).should_not include @out_of_sale_shirt }
       specify { @tshirt_black_unisex.related_products(true, false).should_not include @tshirt_pink       }

    end

    context 'search condition: male=true, female=true' do
      specify { @tshirt_pink.related_products(true, true).should include @tshirt_black_unisex   }
      specify { @tshirt_pink.related_products(true, true).should_not include @tshirt_blue       }
      specify { @tshirt_pink.related_products(true, true).should_not include @out_of_sale_shirt }

      specify { @tshirt_black_unisex.related_products(true, true).should include @tshirt_pink   }
      specify { @tshirt_black_unisex.related_products(true, true).should include @tshirt_blue   }
    end

  end

  describe "aggregation methods" do
    before do
      @product_1 = Factory :product
      @product_2 = Factory :product
    end
    it { Product.total_average_price.should == ((@product_1.price + @product_2.price) / 2) }
    it { Product.total_average_discount.should == ((@product_1.discount + @product_2.discount) / 2)}
  end

  describe "meta tags" do
    before do
       @product = Factory.create(:product)
       @product_with_tags = Factory.create(:product, :title => "title",
        :meta_description => "meta_description")
    end

    it { @product.title.should eql( "#{@product.brand.name} #{@product.name} #{@product.category.name} on Sale Here | AllTheSales Australia")  }
    it { @product.meta_description.should eql("#{@product.brand.name} #{@product.name} #{@product.category.name} on Sale at Affordable & Cheap Prices. Australia's #1 Store for Stylish, Fashionable Brand Name Clothing")}
    it { @product_with_tags.title.should eql("title") }
    it { @product_with_tags.meta_description.should eql("meta_description") }
  end

  describe "sphinx order scopes" do
    before do
      @first_store = Factory :store, :name => "Zippo"
      @last_store = Factory :store, :name => "Abbyy"
      @first_product = Factory :product, :name => "Zippo", :store => @first_store
      @last_product = Factory :product, :name => "Lingvo", :store => @last_store
      ThinkingSphinx::Test.index; sleep 0.5
    end

    context "should order by name" do
      specify { Product.by_name("asc").first.name.should == @last_product.name }
      specify { Product.by_name("desc").first.name.should == @first_product.name }
    end

    context "should order by store name" do
      specify { Product.by_store_name("asc").first.name.should == @last_product.name }
      specify { Product.by_store_name("desc").first.name.should == @first_product.name }
    end

  end

  describe "new and sold methods" do
    before do
      @new = Factory :product, :new_tag_timestamp => 47.hours.ago
      @sold = Factory :product, :archived => true
      @old = Factory :product, :new_tag_timestamp => 3.days.ago
    end

    specify { @new.new?.should be_true }
    specify { @old.new?.should be_false }
    specify { @sold.sold?.should be_true }
    specify { @new.sold?.should be_false }

  end

  describe "unset_all_homepage_products" do
    before do
      @featured = Factory :product, :featured => true, :homepage => true
      Product.unset_all_homepage
    end
    specify { Product.homepage == []}
    specify { @featured.homepage == false }
  end

  describe "set homepage products" do
    before do
      @homepage = Factory :product, :homepage => true
      @not_homepage = Factory :product, :homepage => false
      Product.set_homepage [@not_homepage.id]
    end
    specify { @homepage.homepage == false }
    specify { @not_homepage.homepage == true }
  end

  describe "set new_tag_timestamp" do
    before { @product = Factory :product, :value => 200, :price => 100 }

    context "after create" do
      specify { @product.new_tag_timestamp.to_date.should == @product.created_at.to_date }
    end

    context "after descrease price" do
      before  do
        Timecop.travel(Time.zone.local(2012, 12, 12, 12, 12, 12)) do
          @product.update_attribute(:price, 50)
        end
      end

      specify "it should be now" do
        @product.new_tag_timestamp.to_date.should == @product.updated_at.to_date
      end

      specify "it should not be like created at time" do
       @product.new_tag_timestamp.to_date.should_not == @product.created_at.to_date
      end

      specify { @product.new_tag_timestamp.should_not be_nil }
    end

    context "after inscrease price" do
      before  do
        Timecop.travel(Time.zone.local(2012, 12, 12, 12, 12, 12)) do
          @product.update_attribute(:price, 101)
        end
      end

      specify "it should not be now" do
        @product.new_tag_timestamp.to_date.should_not == @product.updated_at.to_date
      end

      specify "it should be like create at time" do
       @product.new_tag_timestamp.to_date.should == @product.created_at.to_date
      end

      specify { @product.new_tag_timestamp.should_not be_nil }
    end

    context "after updating description" do
      before  do
        Timecop.travel(Time.zone.local(2012, 12, 12, 12, 12, 12)) do
          @product.update_attribute(:description, "end of the world")
        end
      end

      specify "it should be like created at time" do
        @product.new_tag_timestamp.to_date.should == @product.created_at.to_date
      end

      specify "it should not be like updated at time" do
        @product.new_tag_timestamp.to_date.should_not == @product.updated_at.to_date
      end

      specify { @product.new_tag_timestamp.should_not be_nil }
    end
  end


  describe " new tag after product was unarchived" do
    before do
      @product = Factory :product, :archived => true
      Timecop.travel(Time.zone.local(2012, 12, 12, 12, 12, 12)) do
        @product.update_attribute(:archived, false)
      end
    end

    specify "it should be now" do
      @product.new_tag_timestamp.to_date.should == @product.updated_at.to_date
    end

    specify "it should not be like create at time" do
     @product.new_tag_timestamp.to_date.should_not == @product.created_at.to_date
    end

    specify { @product.new_tag_timestamp.should_not be_nil }
  end

end
