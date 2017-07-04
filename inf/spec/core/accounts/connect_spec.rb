require 'rails_helper'

describe Accounts::Connect do
  context 'success' do
    let(:customer) { create(:customer) }
    let(:service) { Accounts::Connect }
    let(:twitter) { providers(:twitter) }
    let(:options) do
      {
        uid: 123,
        provider_id: twitter.id,
        token: 'ss',
        username: 'aa',
        name: 'bb',
        expires_at: Time.now.utc + 2.years,
        secret: 'ddd'
      }
    end

    def account_params(p = {})
      options.merge(p)
    end

    specify 'create account' do
      service.new(customer, options).query
      account = Account.last
      fields = %i(token secret name username expires_at customer active)
      fields.each { |field| expect(account.send(field)).to be_truthy }
    end

    specify 'update token' do
      p = account_params(token: 'kk')
      service.new(customer, p).query
      account = Account.last
      expect(account.token).to eq 'kk'
    end
  end
end
