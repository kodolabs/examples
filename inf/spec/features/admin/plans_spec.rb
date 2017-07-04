require 'rails_helper'

feature 'Admin Plans' do
  let(:admin) { create :admin }
  before { admin_sign_in admin }

  specify 'can see full list of plans' do
    plans = Array.new(2) { create(:plan) }
    visit admin_plans_path
    plans.each do |plan|
      expect(page).to have_content(plan.name)
      expect(page).to have_content(plan.price_monthly)
      expect(page).to have_content(plan.price_annual)
      expect(page).to have_content(plan.stripe_id_monthly)
      expect(page).to have_content(plan.stripe_id_annual)
    end
  end

  specify 'can create new plan' do
    stripe_id_monthly = SecureRandom.hex
    stripe_id_annual = SecureRandom.hex
    visit admin_plans_path
    find('.page-header a').click

    within '#new_plan_' do
      fill_in 'Name', with: 'New plan name'
      fill_in 'Monthly Price', with: 12.34
      fill_in 'Annual Price', with: 123.4
      fill_in 'Max Social Accounts', with: 2
      fill_in 'Monthly Stripe plan ID', with: stripe_id_monthly
      fill_in 'Annual Stripe plan ID', with: stripe_id_annual
      click_on 'Save'
    end

    expect(page).to have_flash('Plan successfully created')
    expect(page).to have_content('New plan name')
    expect(page).to have_content(12.34)
    expect(page).to have_content(12.34)
    expect(page).to have_content(stripe_id_monthly)
    expect(page).to have_content(stripe_id_annual)
  end

  specify 'can update existing plan' do
    plan = create(:plan)
    new_stripe_id_monthly = SecureRandom.hex
    new_stripe_id_annual = SecureRandom.hex

    visit admin_plans_path
    click_on plan.name

    within 'form' do
      fill_in 'Name', with: 'Updated plan name'
      fill_in 'Monthly Price', with: 43.21
      fill_in 'Annual Price', with: 432.1
      fill_in 'Monthly Stripe plan ID', with: new_stripe_id_monthly
      fill_in 'Annual Stripe plan ID', with: new_stripe_id_annual
      click_on 'Save'
    end

    expect(page).to have_current_path(admin_plans_path)
    expect(page).to have_flash('Plan successfully updated')
    expect(page).to have_content('Updated plan name')
    expect(page).to have_content(43.21)
    expect(page).to have_content(432.1)
    expect(page).to have_content(new_stripe_id_monthly)
    expect(page).to have_content(new_stripe_id_annual)
  end

  specify 'can remove existing plan' do
    create(:plan)
    visit admin_plans_path
    find('tr:first-child a[data-method="delete"]').click

    expect(page).to have_current_path(admin_plans_path)
    expect(page).to have_flash('Plan successfully deleted')
  end
end
