require 'rails_helper'

describe Domains::CalculateUptime do
  describe '.call' do
    let!(:domain) { create :domain, status: :active }
    let!(:monitoring) { domain.monitorings.uptime.first }

    context 'should return zero' do
      it 'if total monitoring histories count equal zero' do
        expect(Domains::CalculateUptime.new(domain, 7.days).call).to eq 0
      end
    end

    context 'should return uptime value' do
      it 'if uptime monitoring has histories in period interval' do
        create :history, :success, monitoring: monitoring, created_at: Time.zone.today - 1.day
        create :history, :error, monitoring: monitoring, created_at: Time.zone.today - 2.days
        expect(Domains::CalculateUptime.new(domain, 7.days).call).to eq 50
      end
    end
  end
end
