require 'rails_helper'

feature 'User Referral' do
  specify 'link should redirect to sign up and save code cookie' do
    visit 'r/CsUtSFIfTichuH'
    expect(page).to have_content 'Sign up'
    cookies = get_me_the_cookies
    expect(cookies[0][:value]).to eq 'CsUtSFIfTichuH'
    expect(cookies[0][:expires].year).to eq(Time.current.year + 1)
  end

  specify 'page should display referral link' do
    customer = create(:customer, :with_active_subscr)
    user_sign_in customer.primary_user
    visit(user_referrals_path)
    expect(page).to have_content 'Your referral code'
    input = find('#referral_link')
    expect(input.value).to eq "http://#{ENV['HOST_NAME']}/r/#{customer.referral_code}"
  end

  specify 'page should display referral history' do
    customer = create(:customer, :with_active_subscr)
    transaction1 = create(:referral_transaction, customer: customer)
    transaction2 = create(:referral_transaction, customer: customer)
    user_sign_in customer.primary_user
    visit(user_referrals_path)
    expect(page).to have_content transaction1.message
    expect(page).to have_content transaction1.decorate.balance_amount
    expect(page).to have_content transaction2.message
    expect(page).to have_content transaction2.decorate.balance_amount
  end

  specify 'page should display message if referral history blank' do
    customer = create(:customer, :with_active_subscr)
    user_sign_in customer.primary_user
    visit(user_referrals_path)
    expect(page).to have_content 'No referral transactions'
  end

  specify 'can share referral link via email' do
    customer = create(:customer, :with_active_subscr)
    user_sign_in customer.primary_user
    visit(user_referrals_path)
    fill_in '_email', with: 'johndoe@example.com'
    click_on 'Send referral link'
    expect(page).to have_flash 'Referral link was successfully sent'
    ActionMailer::Base.deliveries.clear
  end
end
