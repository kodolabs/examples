require 'rails_helper'

feature 'HostAccount' do
  let!(:domain) { create :domain }
  let!(:blog) { create :blog }
  let!(:host) { create :host, domain: domain, blog: blog }
  let!(:provider) { create :provider, provider_type: :host, alias: 'alias', name: 'Main' }
  let!(:account) { create :account, provider: provider }

  before do
    user_sign_in
  end

  describe 'create new host account', js: true do
    it 'exists account' do
      visit new_host_account_path

      expect(HostAccount.count).to eq 0
      expect(page).to have_content I18n.t('host_accounts.new.title')

      select_option('account_id', account.login, 'input')
      fill_in 'host_account_login', with: 'example_login'
      fill_in 'host_account_password', with: '1234567'
      fill_in 'host_account_location', with: 'Moscow'
      fill_in 'host_account_ip', with: '127.0.0.1'
      fill_in 'host_account_url', with: 'http://example.com'
      fill_in 'host_account_expires_at', with: Time.zone.now.strftime('%d/%m/%Y')

      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.host_account_created')
      expect(HostAccount.count).to eq 1

      host_account = HostAccount.last

      expect(host_account.account_id).to eq account.id
      expect(host_account.login).to eq 'example_login'
      expect(host_account.url).to eq 'http://example.com'
      expect(host_account.expires_at).to eq Time.zone.today

      expect(page).to have_content host_account.account.login
      expect(page).to have_content host_account.provider.name
      expect(page).to have_content host_account.login
    end

    it 'invalid form' do
      visit new_host_account_path

      click_button 'Create'
      expect(page).to have_content "can't be blank"
      expect(page).to have_selector('.field_with_errors', count: 2)
      expect(page).to have_selector('.help-block.error', count: 1)
    end

    it 'create with new account', js: true do
      visit new_host_account_path

      expect(Account.count).to eq 1
      expect(HostAccount.count).to eq 0

      click_link 'Add'
      modal = page.find('#account-modal')

      expect(modal).to have_content I18n.t('accounts.new.title')
      select_option('account_provider_id', provider.name, 'select')
      fill_in 'account_login', with: 'New Account'
      fill_in 'account_password', with: 'account_password'

      modal.find('input[type="submit"]').click

      wait_by_true(modal.visible?)

      expect(Account.count).to eq 2

      select_option('account_id', 'New Account', 'input')
      fill_in 'host_account_login', with: 'example_login'
      fill_in 'host_account_password', with: '1234567'
      fill_in 'host_account_location', with: 'Moscow'
      fill_in 'host_account_ip', with: '127.0.0.1'
      fill_in 'host_account_url', with: 'http://example.com'
      fill_in 'host_account_expires_at', with: Time.zone.now.strftime('%d/%m/%Y')

      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.host_account_created')
      expect(HostAccount.count).to eq 1

      expect(page).to have_content 'New Account'
    end

    it 'create account with new provider', js: true do
      visit new_host_account_path

      expect(Provider.count).to eq 1
      expect(Account.count).to eq 1
      expect(HostAccount.count).to eq 0

      click_link 'Add'
      modal = page.find('#account-modal')
      modal.find('#account_add_new_provider').trigger('click')

      fill_in 'account_login', with: 'New Account'
      fill_in 'account_password', with: 'account_password'

      fill_in 'account_name', with: 'New provider'
      fill_in 'account_alias', with: 'new alias'
      fill_in 'account_url', with: 'http://example.com'

      modal.find('input[type="submit"]').click

      wait_by_true(modal.visible?)

      expect(Provider.count).to eq 2
      expect(Account.count).to eq 2
    end
  end

  describe 'create new host account modal', js: true do
    it 'invalid form' do
      visit edit_domain_host_path(domain, host)
      click_link 'Add'
      modal = page.find('#host-account-modal')
      modal.find('input[type="submit"]').click
      wait_by_true(modal.visible?)
      expect(page).to have_content "can't be blank"
      expect(page).to have_selector('.field_with_errors', count: 3)
    end

    it 'with exists account' do
      visit edit_domain_host_path(domain, host)
      click_link 'Add'
      modal = page.find('#host-account-modal')

      select_option('host_account_modal_account_id', account.login, 'select')
      fill_in 'host_account_modal_login', with: 'example_login'
      fill_in 'host_account_modal_password', with: '1234567'
      fill_in 'host_account_modal_ip', with: '127.0.0.1'
      fill_in 'host_account_modal_url', with: 'http://example.com'
      fill_in 'host_account_modal_location', with: 'Moscow'
      fill_in 'host_account_modal_expires_at', with: Time.zone.now.strftime('%d/%m/%Y')

      modal.find('input[type="submit"]').click
      wait_by_true(modal.visible?)

      expect(HostAccount.count).to eq 1
      host_account = HostAccount.last

      expect(host_account.account_id).to eq account.id
      expect(host_account.login).to eq 'example_login'
      expect(host_account.password).to eq '1234567'
      expect(host_account.location).to eq 'Moscow'
      expect(host_account.ip).to eq '127.0.0.1'
      expect(host_account.url).to eq 'http://example.com'
      expect(host_account.expires_at).to eq Time.zone.today
    end

    it 'with new account and exists provider', js: true do
      expect(Provider.count).to eq 1
      expect(Account.count).to eq 1
      expect(HostAccount.count).to eq 0

      visit edit_domain_host_path(domain, host)
      click_link 'Add'
      modal = page.find('#host-account-modal')

      modal.find('#host_account_modal_add_new_account').trigger('click')

      select_option('host_account_modal_account_provider_id', provider.name, 'select')
      fill_in 'host_account_modal_account_login', with: 'New Account'
      fill_in 'host_account_modal_account_password', with: 'account_password'

      fill_in 'host_account_modal_login', with: 'example_login'
      fill_in 'host_account_modal_password', with: '1234567'
      fill_in 'host_account_modal_ip', with: '127.0.0.1'
      fill_in 'host_account_modal_url', with: 'http://example.com'
      fill_in 'host_account_modal_location', with: 'Moscow'
      fill_in 'host_account_modal_expires_at', with: Time.zone.now.strftime('%d/%m/%Y')

      modal.find('input[type="submit"]').click

      wait_by_true(modal.visible?)

      expect(HostAccount.count).to eq 1
      expect(Account.count).to eq 2
      expect(Provider.count).to eq 1
    end

    it 'with new account and new provider', js: true do
      expect(Provider.count).to eq 1
      expect(Account.count).to eq 1
      expect(HostAccount.count).to eq 0

      visit edit_domain_host_path(domain, host)
      click_link 'Add'
      modal = page.find('#host-account-modal')

      modal.find('#host_account_modal_add_new_account').trigger('click')

      select_option('host_account_modal_account_provider_id', provider.name, 'select')

      modal.find('#host_account_modal_add_new_provider').trigger('click')

      fill_in 'host_account_modal_provider_name', with: 'New Provider'
      fill_in 'host_account_modal_provider_alias', with: 'New Provider Alias'
      fill_in 'host_account_modal_provider_url', with: 'http://example.com'

      fill_in 'host_account_modal_account_login', with: 'New Account'
      fill_in 'host_account_modal_account_password', with: 'account_password'

      fill_in 'host_account_modal_login', with: 'example_login'
      fill_in 'host_account_modal_password', with: '1234567'
      fill_in 'host_account_modal_ip', with: '127.0.0.1'
      fill_in 'host_account_modal_url', with: 'http://example.com'
      fill_in 'host_account_modal_location', with: 'Moscow'
      fill_in 'host_account_modal_expires_at', with: Time.zone.now.strftime('%d/%m/%Y')

      modal.find('input[type="submit"]').click

      wait_by_true(modal.visible?)

      expect(HostAccount.count).to eq 1
      expect(Account.count).to eq 2
      expect(Provider.count).to eq 2
    end
  end
end
