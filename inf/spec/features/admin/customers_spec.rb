require 'rails_helper'

feature 'Customers' do
  let!(:admin) { create :admin }
  let!(:customer1) { create(:customer, :with_active_subscr, :with_topics) }
  let!(:customer2) { create(:customer, :with_active_subscr) }
  let!(:card1) { create(:card, customer: customer1) }
  let!(:card2) { create(:card, customer: customer2) }
  let!(:subscription) { create(:subscription, customer: customer1) }
  let!(:payment) { create(:payment, subscription: subscription, card: card1) }
  let(:topic) { customer1.topics.last }

  context 'when admin logged in' do
    before { admin_sign_in admin }

    it 'can see list of cutomers with profile' do
      visit admin_customers_path

      expect(page).to have_content 'Customers'

      [customer1, customer2].map(&:decorate).each do |customer|
        profile = customer.primary_user.profile
        expect(page).to have_content customer.primary_user.email
        expect(page).to have_content profile.full_name
        expect(page).to have_content profile.phone
        expect(page).to have_content customer.status
      end
    end

    it 'can log in as customer' do
      visit admin_customers_path

      expect(page).to have_content 'Customers'
      expect(page).to have_button 'Login'
      tr = page.find('tr', text: customer1.primary_user.email)
      tr.find_button('Login').click
      expect(page).to have_content customer1.primary_user.profile.full_name
      expect(page).to have_content 'Back to admin'
      click_on 'Back to admin'
      expect(current_path).to eq(admin_customers_path)
    end

    it 'can see profile of customer' do
      visit admin_customers_path
      click_on customer1.decorate.full_name
      expect(page).to have_content customer1.decorate.phone
      expect(page).to have_content customer1.plan.try(:name_with_price)
      expect(page).to have_content customer1.referral_code
      expect(page).to have_content customer1.referral_balance.amount
    end

    it 'can edit customer' do
      visit admin_customers_path
      click_on customer1.decorate.full_name
      click_on 'Edit'
      fill_in 'Full name', with: ''
      click_on 'Update'
      expect(page).to have_content "can't be blank"

      fill_in 'Full name', with: 'Kodo'
      click_on 'Update'
      expect(page).to have_flash 'Customer successfully updated'
      expect(page).to have_content 'Kodo'
    end

    it 'can see referral history' do
      create :referral_transaction, customer: customer1, amount: 200, message: 'user'
      create :referral_transaction, customer: customer1, amount: -150, message: 'admin'
      visit referral_transactions_admin_customer_path(customer1)
      expect(page).to have_content '+ $200'
      expect(page).to have_content 'user'
      expect(page).to have_content '- $150'
      expect(page).to have_content 'admin'
    end

    it "can see list of customer's accounts" do
      facebook_acc = create :account, :facebook, customer: customer1
      twitter_acc = create :account, :twitter, customer: customer1
      visit accounts_admin_customer_path(customer1)
      expect(page).to have_content facebook_acc.decorate.connected_title
      expect(page).to have_content twitter_acc.decorate.connected_title
    end

    it 'can see subscription and payments info of customer' do
      visit subscription_admin_customer_path(customer1)
      expect(page).to have_content card1.brand
      expect(page).to have_content card1.last4
      expect(page).to have_content payment.description
      expect(page).to have_content payment.amount
    end

    it "can disconnect customer's account" do
      create :account, :facebook, customer: customer1
      visit accounts_admin_customer_path(customer1)
      click_link 'Disconnect'
      expect(page).to have_flash I18n.t('account.disconnected')
    end
  end
end
