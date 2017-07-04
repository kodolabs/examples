require 'rails_helper'

feature 'HostAccountIndex' do
  let!(:provider) { create :provider, provider_type: :host, alias: 'alias', name: 'Main' }
  let!(:new_provider) { create :provider, provider_type: :host, alias: 'alias', name: 'Other provider' }

  let!(:account) { create :account, provider: provider, login: 'test_login' }
  let!(:new_account) { create :account, provider: new_provider, login: 'new_account' }

  let!(:host_account_test) { create :host_account, login: 'test', account: account, active: true }
  let!(:host_account_wp) { create :host_account, login: 'wordpress', account: account, active: true }
  let!(:host_account_wp_2) { create :host_account, login: 'wordpress', account: new_account, active: false }
  let!(:host_account_admin) { create :host_account, login: 'admin', account: account, active: false }

  before do
    user_sign_in
  end

  describe 'index' do
    it 'should show active host accounts' do
      visit host_accounts_path
      expect(page).to have_content host_account_test.login
      expect(page).to have_content host_account_wp.login
      expect(page).to have_content 'Showing all 2 host accounts'
    end

    it 'should show inactive host accounts' do
      visit inactive_host_accounts_path
      expect(page).to have_content host_account_wp_2.login
      expect(page).to have_content host_account_admin.login
      expect(page).to have_content 'Showing all 2 host accounts'
    end

    it 'filter by host account login' do
      visit host_accounts_path

      expect(page).to have_selector('.host-accounts tbody tr', count: 2)

      fill_in 'host_accounts_grid_search_host_account', with: 'test'
      page.find('.host-account-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 1)

      fill_in 'host_accounts_grid_search_host_account', with: 'wordpress'
      page.find('.host-account-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 1)

      fill_in 'host_accounts_grid_search_host_account', with: 'admin'
      page.find('.host-account-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 0)

      fill_in 'host_accounts_grid_search_host_account', with: 'qwerty'
      page.find('.host-account-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 0)
    end

    it 'filter by account login' do
      visit host_accounts_path

      expect(page).to have_selector('.host-accounts tbody tr', count: 2)

      fill_in 'host_accounts_grid_search_account', with: 'test_login'
      page.find('.account-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 2)

      fill_in 'host_accounts_grid_search_account', with: 'new_account'
      page.find('.account-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 0)

      fill_in 'host_accounts_grid_search_account', with: 'new'
      page.find('.account-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 0)

      fill_in 'host_accounts_grid_search_account', with: 'qwerty'
      page.find('.account-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 0)
    end

    it 'filter by provider' do
      visit host_accounts_path

      expect(page).to have_selector('.host-accounts tbody tr', count: 2)

      fill_in 'host_accounts_grid_search_provider', with: provider.name
      page.find('.provider-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 2)

      fill_in 'host_accounts_grid_search_provider', with: new_provider.name
      page.find('.provider-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 0)

      fill_in 'host_accounts_grid_search_provider', with: 'test'
      page.find('.provider-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 0)
    end

    it 'multiple filters' do
      visit host_accounts_path

      expect(page).to have_selector('.host-accounts tbody tr', count: 2)
      expect(page).to have_content(account.login)
      expect(page).to have_content(provider.name)

      fill_in 'host_accounts_grid_search_host_account', with: host_account_test.login
      fill_in 'host_accounts_grid_search_account', with: host_account_test.account.login
      fill_in 'host_accounts_grid_search_provider', with: host_account_test.provider.name
      page.find('.host-account-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 1)

      fill_in 'host_accounts_grid_search_provider', with: new_provider.name
      page.find('.provider-search .submit-search').click

      expect(page).to have_selector('.host-accounts tbody tr', count: 0)
    end
  end

  describe 'edit modals' do
    let!(:provider_for_edit) do
      create :provider, provider_type: :host, alias: 'alias', name: 'created-provider'
    end
    let!(:account_for_edit) { create :account, provider: provider_for_edit, login: 'created-account' }
    let!(:host_account_for_edit) do
      create :host_account, login: 'created-test', account: account_for_edit, active: true
    end

    it 'should success edit provider', js: true do
      visit host_accounts_path

      expect(page).to have_content host_account_for_edit.login
      expect(host_account_for_edit.provider).to eq provider_for_edit
      expect(page).to have_content provider_for_edit.name
      expect(provider_for_edit.name).to eq 'created-provider'
      expect(provider_for_edit.alias).to eq 'alias'

      click_link provider_for_edit.name

      modal = page.find('#provider-edit-modal')

      fill_in 'provider_name', with: 'Edited provider'
      fill_in 'provider_alias', with: 'edited_alias'
      fill_in 'provider_url', with: 'http://google.com'

      modal.find('input[type="submit"]').click
      wait_by_true(modal.visible?)

      provider_for_edit.reload

      expect(provider_for_edit.name).to have_content 'Edited provider'
      expect(provider_for_edit.alias).to have_content 'edited_alias'
      expect(provider_for_edit.url).to have_content 'http://google.com'

      expect(page).to have_content 'Edited provider'

      visit host_accounts_path

      expect(page).to have_content 'Edited provider'
    end

    it 'should success edit account', js: true do
      visit host_accounts_path

      expect(page).to have_content account_for_edit.login
      expect(account_for_edit.login).to eq 'created-account'

      click_link account_for_edit.login

      modal = page.find('#account-edit-modal')

      fill_in 'base_login', with: 'edited-account'
      fill_in 'base_password', with: 'new-password'

      modal.find('input[type="submit"]').click
      wait_by_true(modal.visible?)

      account_for_edit.reload

      expect(account_for_edit.login).to have_content 'edited-account'
      expect(account_for_edit.password).to have_content 'new-password'

      expect(page).to have_content 'edited-account'

      visit host_accounts_path

      expect(page).to have_content 'edited-account'
    end

    it 'should success edit host account', js: true do
      visit host_accounts_path

      expect(page).to have_content host_account_for_edit.login
      expect(host_account_for_edit.login).to eq 'created-test'

      click_link host_account_for_edit.login

      modal = page.find('#host-account-edit-modal')

      fill_in 'host_account_login', with: 'edited-host-account'
      fill_in 'host_account_password', with: 'new-host-password'

      modal.find('input[type="submit"]').click
      wait_by_true(modal.visible?)

      host_account_for_edit.reload

      expect(host_account_for_edit.login).to have_content 'edited-host-account'
      expect(host_account_for_edit.password).to have_content 'new-host-password'

      expect(page).to have_content 'edited-host-account'

      visit host_accounts_path

      expect(page).to have_content 'edited-host-account'
    end
  end
end
