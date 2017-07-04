require 'rails_helper'

describe Providers::HostAccountIds do
  describe '.call' do
    let!(:provider) { create :provider }
    let!(:account1) { create :account, provider: provider }
    let!(:account2) { create :account, provider: provider }

    context 'should return empty array' do
      it 'if accounts without host accounts' do
        expect(Providers::HostAccountIds.new(provider).query).to eq([])
      end
    end

    context 'should return array' do
      it 'with host account ids' do
        3.times { create :host_account, account: account1 }
        2.times { create :host_account, account: account2 }
        ids = Providers::HostAccountIds.new(provider).query
        expect(ids.count).to eq(5)
        expect(ids).to eq(HostAccount.all.pluck(:id))
      end
    end
  end
end
