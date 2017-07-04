require 'rails_helper'

describe Tasks::CreateDomainUptimeTask do
  describe '.call' do
    let!(:domain) { create :domain, status: :active }
    let!(:monitoring) { domain.monitorings.uptime.first }

    context 'should not create uptime task' do
      it 'if uptime more than limit' do
        create :history, :success, monitoring: monitoring, created_at: Time.zone.today - 1.day
        create :history, :success, monitoring: monitoring, created_at: Time.zone.today - 2.days
        Tasks::CreateDomainUptimeTask.call(domain: domain)
        expect(Task.uptime.count).to eq 0
      end

      it 'if three days silence' do
        create :history, :success, monitoring: monitoring, created_at: Time.zone.today - 1.day
        create :history, :error, monitoring: monitoring, created_at: Time.zone.today - 2.days
        signature = "uptime:domain_#{domain.id}:#{(Time.zone.today - 2.days).strftime('%Y%m%d')}"
        create :task, :pending, :uptime, signature: signature
        Tasks::CreateDomainUptimeTask.call(domain: domain)
        expect(Task.uptime.count).to eq 1
      end
    end

    context 'should create uptime task' do
      it 'if uptime low than limit' do
        create :history, :success, monitoring: monitoring, created_at: Time.zone.today - 1.day
        create :history, :error, monitoring: monitoring, created_at: Time.zone.today - 2.days
        Tasks::CreateDomainUptimeTask.call(domain: domain)
        expect(Task.uptime.count).to eq 1
      end

      it 'if last uptime task is not in tree days silence interval' do
        create :history, :success, monitoring: monitoring, created_at: Time.zone.today - 1.day
        create :history, :error, monitoring: monitoring, created_at: Time.zone.today - 2.days
        signature = "uptime:domain_#{domain.id}:#{(Time.zone.today - 4.days).strftime('%Y%m%d')}"
        create :task, :pending, :uptime, signature: signature
        Tasks::CreateDomainUptimeTask.call(domain: domain)
        expect(Task.uptime.count).to eq 2
      end
    end
  end
end
