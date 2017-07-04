require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'check' do
    it 'collection should be login + provider' do
      account = create :account

      collection = Account.collection

      expect(collection.size).to eq 1
      expect(collection.first.size).to eq 2
      expect(collection.first[:label]).to include account.login
      expect(collection.first[:label]).to include account.provider.name
      expect(collection.first[:value]).to eq account.id
    end

    it 'collections return account by provider type' do
      dns_provider = create :provider, provider_type: :dns
      host_provider = create :provider, provider_type: :host
      account_dns = create :account, provider: dns_provider, login: 'login 1'
      second_account_dns = create :account, provider: dns_provider, login: 'login 2'
      account_host = create :account, provider: host_provider

      dns_collection = Account.dns_collection

      expect(dns_collection.size).to eq 2
      expect(dns_collection.first.size).to eq 2
      expect(dns_collection.first[:label]).to include account_dns.login
      expect(dns_collection.first[:label]).to include dns_provider.name
      expect(dns_collection.first[:value]).to eq account_dns.id

      expect(dns_collection.second[:label]).to include second_account_dns.login
      expect(dns_collection.second[:label]).to include dns_provider.name
      expect(dns_collection.second[:value]).to eq second_account_dns.id

      host_collection = Account.host_collection

      expect(host_collection.size).to eq 1

      first_record = host_collection.first
      expect(first_record.size).to eq 2
      expect(first_record.first).to include account_host.login
      expect(first_record.first).to include host_provider.name
      expect(first_record.second).to eq account_host.id
    end

    it 'select method should be search by ID' do
      account = create :account

      expect(Account.select(account.id)).to eq account
    end
  end
end
