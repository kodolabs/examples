require 'rails_helper'

describe HostAccounts::ValidateLoginUniqueness do
  let!(:account) { create :account }

  describe '.call' do
    context 'success validation' do
      it 'should be valid' do
        create :host_account, account: account, active: true, login: 'somelogin'
        validation = HostAccounts::ValidateLoginUniqueness.new(account.id, 'login', nil).valid?
        expect(validation).to be_truthy
      end

      it 'should be valid if host account is inactive' do
        create :host_account, account: account, active: false, login: 'somelogin'
        validation = HostAccounts::ValidateLoginUniqueness.new(account.id, 'somelogin', nil).valid?
        expect(validation).to be_truthy
      end

      it 'should not be valid' do
        create :host_account, account: account, active: true, login: 'somelogin'
        validation = HostAccounts::ValidateLoginUniqueness.new(account.id, 'somelogin', nil).valid?
        expect(validation).to be_falsey
      end

      it 'should not be valid if account is present' do
        host_account = create :host_account, account: account, active: true, login: 'somelogin'
        validation = HostAccounts::ValidateLoginUniqueness.new(
          account.id, 'somelogin', host_account.id
        ).valid?
        expect(validation).to be_truthy
      end
    end
  end
end
