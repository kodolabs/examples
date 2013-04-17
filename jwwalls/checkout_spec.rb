require 'spec_helper'

describe "Checkout" do
  let(:site)            { sites(:jwwalls)}
  let(:material)        { sites(:jwwalls).materials.first }
  let(:product)         { Factory :live_product }
  let(:user)            { Factory(:customer).user }
  let(:design)          { Factory :product_design, user: user, designable: product, wall_width: 600 }
  let(:accessory)       { Factory :accessory }
  let(:cart)            { Factory :cart }

  before  { set_current_site_for_requests(site.hostname) }
  before  { CartLoader.stub(:load).and_return(cart) }

  context "as signed in user" do
    before { sign_in_as_user(user) }

    specify "checking out as logged in user" do

      add_to_cart_fast(cart, design)
      visit cart_path

      choose "cart_installation_false"

      click_button 'Proceed'
      page.should have_content 'Delivery address'
      click_button "Next"

      page.should have_content 'Please, enter your payment details below'

      fill_in_payment_data
      fill_in_customer_address

      expect{ click_button "Next"; wait_until {page.has_content? 'Thanks for your order'} }.to change(ActionMailer::Base.deliveries, :size).by(2)

      within ".cart_size" do
        page.should have_content "(0)"
      end

      within ".cart_total" do
        page.should have_content "0.00"
      end
    end

    describe "buy product and choose installation" do
      specify do
        add_to_cart_fast(cart, design)

        visit cart_path
        choose "cart_installation_true"
        click_button 'Proceed'

        page.should have_content 'Installation address'

        expect{ click_button "Next"; wait_until {page.has_content? 'Thanks for your installation request'} }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end
    end

    describe 'pay with errors' do
      let(:xpay_payment) { mock }
      before do
        @order = Factory.build :order_for_payment
        Order.any_instance.stub(:xpay_payment).and_return(xpay_payment)

        add_to_cart_fast(cart, design)

        visit new_order_path

        fill_in_customer_address
      end

      context "errors in model" do
        before do
          fill_in_incorrect_payment_data
          click_button "Next"
        end

        specify do
          page.should have_content "can't be blank"
        end
      end

      context 'errors from xpay' do
        before do
          xpay_payment.should_receive(:make_payment).and_return(0)
          xpay_payment.should_receive(:response_block).and_return({:error_code => 'declined message'})
          fill_in_payment_data
          click_button "Next"
        end

        specify "should see xpay errors" do
          page.should have_content "declined message"
        end
      end
    end

    specify "cart has items should skip login screen" do
      add_to_cart_fast(cart, design)
      visit new_authorization_path
      page.should have_content "Please enter your delivery address below"
    end
  end

  specify "checking out as not logged in user", :js do
    add_to_cart_fast(cart, design)
    add_to_cart_fast(cart, accessory)

    choose "cart_installation_false"
    click_button 'Proceed'

    # sign in page
    page.should have_content 'Ready to order?'

    # go to next page
    within '.continue-box' do
      click_on 'Continue'
    end

    # customer details page
    page.should have_content 'Please enter your delivery address below'
    fill_in_user_and_customer_details

    # billing details page
    fill_in_payment_data
    fill_in_customer_address

    click_button "Next"
    page.should have_content 'Thanks for your order'

    within ".cart_size" do
      page.should have_content "(0)"
    end

    within ".cart_total" do
      page.should have_content "0.00"
    end
  end

  specify "proceeding to checkout with empty cart" do
    visit new_order_path
    page.should have_content 'Your shopping basket'
  end

  specify "should not be able visit authorization page if my cart is empty" do
    visit new_authorization_path
    page.should have_content "Customise to fit your wall" #content from homepage
  end
end
