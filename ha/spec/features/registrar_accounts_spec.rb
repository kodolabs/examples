require 'rails_helper'

feature 'RegistrarAccount' do
  let!(:domain) { create :domain }
  let!(:blog) { create :blog }
  let!(:host) { create :host, domain: domain, blog: blog }
  let!(:provider) { create :provider, provider_type: :dns, alias: 'alias', name: 'Main' }

  before do
    user_sign_in
  end

  describe 'create new registrar account', js: true do
    it 'success' do
      visit new_registrar_accounts_path

      expect(Account.count).to eq 0

      select_option('provider_id', provider.name, 'input')
      fill_in 'provider_account_login', with: 'example_login'
      fill_in 'provider_account_password', with: '1234567'

      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.registrar_account_created')
      expect(Account.count).to eq 1

      account = Account.last

      expect(account.provider_id).to eq provider.id
      expect(account.login).to eq 'example_login'
      expect(account.password).to eq '1234567'
    end

    it 'invalid form' do
      visit new_registrar_accounts_path

      click_button 'Create'
      expect(page).to have_content "can't be blank"
      expect(page).to have_selector('.field_with_errors', count: 2)
      expect(page).to have_selector('.help-block.error', count: 1)
    end

    it 'create with new provider', js: true do
      visit new_registrar_accounts_path

      expect(Provider.count).to eq 1
      expect(Account.count).to eq 0

      click_link 'Add'
      modal = page.find('#provider-modal')

      fill_in 'provider_name', with: 'New Provider'

      modal.find('input[type="submit"]').click

      wait_by_true(modal.visible?)

      expect(Provider.count).to eq 2

      select_option('provider_id', 'New Provider', 'input')
      fill_in 'provider_account_login', with: 'example_login'
      fill_in 'provider_account_password', with: '1234567'

      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.registrar_account_created')
      expect(Account.count).to eq 1
      expect(Account.first.provider.provider_type).to eq 'dns'
    end
  end
end
