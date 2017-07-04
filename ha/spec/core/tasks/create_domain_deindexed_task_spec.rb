require 'rails_helper'

describe Tasks::CreateDomainDeindexedTask do
  describe '.call' do
    context 'should create domain deindex task' do
      it 'if domains index status is not_indexed' do
        domain = create :domain, index_status: :not_indexed
        Tasks::CreateDomainDeindexedTask.call(domain: domain)
        expect(Task.count).to eq(1)
        expect(Task.first.category).to eq('deindexed')
      end
    end

    context 'should not create domain deindex task' do
      it 'if domains index status is not not_indexed' do
        domain = create :domain, index_status: :indexed
        Tasks::CreateDomainDeindexedTask.call(domain: domain)
        expect(Task.count).to eq(0)
      end
    end
  end
end
