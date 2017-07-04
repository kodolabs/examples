require 'rails_helper'

describe Tasks::CategoryCounters do
  describe '.query' do
    context 'should return hash' do
      it 'with count of each inspections category' do
        domain = create :domain
        3.times { create :task, :deindexed, status: :pending, taskable: domain, title: 'Deindexed Task' }
        2.times { create :task, :uptime, status: :pending, taskable: domain, title: 'Uptime Task' }
        4.times { create :task, :hacked, status: :pending, taskable: domain, title: 'Hacked Task' }
        2.times { create :task, :hacked, status: :in_progress, taskable: domain, title: 'Hacked Task' }
        1.times { create :task, :payment, status: :pending, taskable: domain, title: 'Hacked Task' }
        counters = Tasks::CategoryCounters.new.query
        counters.should be_a(Hash)
        expect(counters).to eq(all: 11, deindexed: 3, uptime: 2, hacked: 6, payment: 1)
      end
    end
  end
end
