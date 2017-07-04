require 'rails_helper'

feature 'Admin Verifications' do
  let(:admin) { create :admin }
  context 'professional' do
    let(:customer) { create(:customer, :with_active_subscr) }
    let(:profile) { customer.profile }
    let(:user) { customer.primary_user }

    context 'when admin logged in', :js do
      before { admin_sign_in admin }

      it 'can see list of pending verifications' do
        create :verification, customer: customer
        visit admin_verifications_path
        expect(page).to have_content user.profile.full_name
      end

      it 'can see list of approved verifications' do
        create :verification, :approved, customer: customer
        visit admin_verifications_path(status: 'approved')
        expect(page).to have_content user.profile.full_name
      end

      it 'can see list of declined verifications' do
        create :verification, :declined, customer: customer
        visit admin_verifications_path(status: 'declined')
        expect(page).to have_content user.profile.full_name
      end

      it 'can approve pending verification' do
        verification = create :verification, customer: customer
        visit admin_verification_path(verification)
        expect(page).to have_content "Verification of #{customer.primary_user.profile.full_name}"
        click_on 'Approve'
        expect(page).to have_content I18n.t('verification.approved')
        customer.reload
        expect(customer.status).to eq 'approved'
      end

      it 'can decline pending verification' do
        verification = create :verification, customer: customer
        visit admin_verification_path(verification)
        expect(page).to have_content "Verification of #{customer.primary_user.profile.full_name}"
        click_on 'Decline'
        expect(page).to have_content I18n.t('verification.declined')
        customer.reload
        expect(customer.status).to eq 'declined'
      end
    end
  end
end
