require 'rails_helper'

describe 'Accounts' do
  context 'Twitter accounts' do
    let(:customer) { create(:customer, :with_active_subscr) }
    let(:account1) { create(:account, :twitter, customer: customer) }
    let(:account2) { create(:account, :twitter, customer: customer) }
    let(:user) { customer.primary_user }
    before(:each) { user_sign_in user }

    specify 'no any accounts' do
      visit user_accounts_path

      within '.accounts-page' do
        within '.info-block__head.initial' do
          expect(page).to have_css '.icon.twitter'
          expect(page).to have_content 'Twitter'
          expect(page).to have_css '.btn-connect'
        end
      end
    end

    specify 'one created account' do
      account1
      visit user_accounts_path

      within '.accounts-page' do
        expect(page).not_to have_css 'right-title'
        expect(page).to have_css '.only-button', count: 1
      end
    end

    specify 'multiple created accounts' do
      account1
      account2
      visit user_accounts_path

      within '.accounts-page' do
        expect(page).to have_css '.right-title', count: 1
        expect(page).to have_css '.only-button', count: 1
      end
    end
  end
end
