require 'rails_helper'

feature 'Edit Domain' do
  let!(:domain_for_edit) do
    create(
      :domain,
      name: 'amazon.com',
      status: :active,
      expires_at: Time.zone.now + 1.day,
      name_servers: %w(yahoo google facebook)
    )
  end
  let!(:other_domain) do
    create(
      :domain,
      name: 'google.com',
      status: :inactive,
      expires_at: Time.zone.now + 2.days
    )
  end

  before do
    user_sign_in
  end

  describe 'Edit page' do
    it 'can update domain' do
      visit edit_domain_path domain_for_edit
      expect(page.find('#edit_name_servers')).to have_content 'yahoo google facebook'

      fill_in 'Name', with: domain_for_edit.name
      fill_in 'Expires at', with: '20.01.2019'
      find('#edit_name_servers').set("new.com\nold.org")
      click_button 'Save'
      expect(page).to have_flash I18n.t('notifications.domain_updated')
      visit edit_domain_path domain_for_edit
      expect(page.find('#edit_name_servers')).to have_content 'new.com old.org'
    end

    it 'can\'t update when' do
      visit edit_domain_path domain_for_edit

      fill_in 'Name', with: other_domain.name
      click_button 'Save'
      expect(page).to have_content I18n.t(
        'notifications.duplicate_domain',
        duplicate_domain: other_domain.name
      )
    end

    it 'can add DNS account', js: true do
      provider = create :provider, provider_type: :dns, alias: 'alias', name: 'Main'
      account = create :account, provider: provider

      expect(domain_for_edit.dns_account).to be_nil

      visit edit_domain_path domain_for_edit

      select_option('dns_account_id', account.label, 'input')
      click_button 'Save'

      expect(domain_for_edit.reload.dns_account).to eq account
    end

    it 'can choose only DNS account', js: true do
      dns_provider = create :provider, provider_type: :dns, alias: 'alias'
      host_provider = create :provider, provider_type: :host, alias: 'alias'
      dns_account = create :account, provider: dns_provider
      host_account = create :account, provider: host_provider

      expect(domain_for_edit.dns_account).to be_nil

      visit edit_domain_path domain_for_edit

      expect(select_option_exists?('dns_account_id', dns_account.label, 'input')).to be_truthy
      expect(select_option_exists?('dns_account_id', host_account.label, 'input')).to be_falsey
    end

    it 'create new DNS account with exists provider', js: true do
      dns_provider = create :provider, provider_type: :dns, alias: 'alias'
      host_provider = create :provider, provider_type: :host, alias: 'alias'

      expect(dns_provider.accounts.count).to eq 0
      expect(domain_for_edit.dns_account).to be_nil

      visit edit_domain_path domain_for_edit

      click_link 'Add'
      modal = page.find('#account-modal')

      expect(modal).to have_content I18n.t('accounts.new.title')
      expect(select_option_exists?('account_provider_id', dns_provider.name, 'select')).to be_truthy
      expect(select_option_exists?('account_provider_id', host_provider.name, 'select')).to be_falsey

      select_option('account_provider_id', dns_provider.name, 'select')

      fill_in 'account_login', with: 'New Account'
      fill_in 'account_password', with: 'account_password'

      modal.find('input[type="submit"]').click

      wait_by_true(modal.visible?)

      expect(dns_provider.reload.accounts.count).to eq 1

      click_button 'Save'

      expect(domain_for_edit.reload.dns_account).to eq dns_provider.accounts.last
    end

    it 'create new DNS provider', js: true do
      expect(Provider.count).to eq 0
      expect(Account.count).to eq 0

      visit edit_domain_path domain_for_edit

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

      expect(Provider.count).to eq 1

      dns_provider = Provider.last
      expect(dns_provider.provider_type).to eq 'dns'
      expect(dns_provider.name).to eq 'New provider'
      expect(dns_provider.alias).to eq 'new alias'
      expect(dns_provider.url).to eq 'http://example.com'

      expect(dns_provider.reload.accounts.count).to eq 1

      click_button 'Save'

      expect(domain_for_edit.reload.dns_account).to eq dns_provider.accounts.last
    end
  end
end
