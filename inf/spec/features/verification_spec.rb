require 'rails_helper'

feature 'User Verification' do
  let(:customer) { create(:customer, :with_profile) }
  let(:file) { Rails.root.join('spec', 'fixtures', 'images', 'customer_logo.jpg') }

  before(:each) { user_sign_in(customer.primary_user) }

  specify 'should be successfully created', :js do
    visit new_user_verification_path
    attach_file('verification_identity', file, visible: :all)
    expect(page).to have_flash I18n.t('verification.sent')
    expect(current_path).to eq(user_profile_subscription_path)
  end

  specify 'button should not displayed if identify is approved' do
    customer.approved!
    visit user_profile_subscription_path
    expect(page).to have_no_flash I18n.t('verification.sent')
  end
end
