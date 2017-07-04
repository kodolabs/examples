require 'rails_helper'

describe HostAccounts::CreateFromModal do
  context 'success' do
    specify 'create host account' do
      account = create :account
      params = {
        account_id: account.id,
        add_new_account: 0,
        add_new_provider: 0,
        login: 'login',
        password: 'password',
        ip: '192.168.0.1',
        url: 'http://example.com',
        location: 'location',
        expires_at:  '10/10/2019'
      }
      form = HostAccounts::HostAccountModalForm.from_params(params)
      expect { HostAccounts::CreateFromModal.call(form) }.to change(HostAccount, :count).to(1)
    end

    specify 'create host account with new account' do
      params = {
        add_new_account: 1,
        account_provider_id: 1,
        account_login: 'accout login',
        account_password: 'accout password',
        add_new_provider: 0,
        login: 'login',
        password: 'password',
        ip: '192.168.0.1',
        url: 'http://example.com',
        location: 'location',
        expires_at:  '10/10/2019'
      }
      form = HostAccounts::HostAccountModalForm.from_params(params)
      HostAccounts::CreateFromModal.call(form)
      expect(HostAccount.count).to eq 1
      expect(Account.count).to eq 1
    end

    specify 'create host account with new account and new provider' do
      params = {
        add_new_account: 1,
        add_new_provider: 1,
        provider_type: 'host',
        provider_name: 'provider name',
        provider_alias: 'provider alias',
        provider_url: 'http://example.com',
        account_login: 'accout login',
        account_password: 'accout password',
        login: 'login',
        password: 'password',
        ip: '192.168.0.1',
        url: 'http://example.com',
        location: 'location',
        expires_at:  '10/10/2019'
      }
      form = HostAccounts::HostAccountModalForm.from_params(params)
      HostAccounts::CreateFromModal.call(form)
      expect(HostAccount.count).to eq 1
      expect(Account.count).to eq 1
      expect(Provider.count).to eq 1
    end
  end
end
