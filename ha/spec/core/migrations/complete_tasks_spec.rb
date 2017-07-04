require 'rails_helper'

describe Migrations::CompleteTasks do
  let!(:user) { create :user }
  let!(:domain) { create :domain, name: 'google.com', status: :active }

  describe '.call' do
    context 'success' do
      it 'should mark inspections tasks as done' do
        3.times { create :task, :deindexed, status: :pending, taskable: domain, title: 'Deindexed Task' }
        2.times { create :task, :uptime, status: :pending, taskable: domain, title: 'Uptime Task' }
        create :task, :payment, status: :pending, taskable: domain, title: 'Payment'
        Migrations::CompleteTasks.new(domain: domain, user: user).call
        expect(Task.done.count).to eq 5
        expect(Task.pending.count).to eq 1
      end
    end
  end
end
