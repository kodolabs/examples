require 'rails_helper'

describe Tasks::CreateUptimeTask do
  describe '.call' do
    context 'should create domain uptime task' do
      it 'if task with same signature not present' do
        domain = create :domain
        Tasks::CreateUptimeTask.new(domain).call
        expect(Task.uptime.count).to eq 1
      end
    end

    context 'should not create domain hacked task' do
      it 'if task with same signature present' do
        domain = create :domain
        signature = "uptime:domain_#{domain.id}:#{Time.zone.today.strftime('%Y%m%d')}"
        create :task, :pending, :uptime, signature: signature, taskable: domain
        Tasks::CreateUptimeTask.new(domain).call
        expect(Task.uptime.count).to eq 1
      end
    end
  end
end
