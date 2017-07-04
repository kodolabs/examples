require 'rails_helper'

describe Tasks::CreateDeindexedTask do
  describe '.call' do
    context 'should create domain deindex task' do
      it 'if task with same signature not present' do
        domain = create :domain
        Tasks::CreateDeindexedTask.new(domain).call
        expect(Task.deindexed.count).to eq 1
      end
    end

    context 'should not create domain deindex task' do
      it 'if task with same signature present' do
        domain = create :domain
        signature = "deindexed:domain_#{domain.id}:#{Time.zone.today.strftime('%Y%m%d')}"
        create :task, :pending, :deindexed, signature: signature, taskable: domain
        Tasks::CreateDeindexedTask.new(domain).call
        expect(Task.deindexed.count).to eq 1
      end
    end
  end
end
