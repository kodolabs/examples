require 'rails_helper'

describe Tasks::CreatePaymentTasks do
  let(:date_today) { Time.zone.now }

  describe '.call' do
    context 'should create domain payment task' do
      before { create :domain, expires_at: date_today + 10.days, status: :inactive }

      it 'if live domains expires date in 14 days interval' do
        create :domain, expires_at: date_today + 10.days
        Tasks::CreatePaymentTasks.call
        expect(Task.count).to eq(1)
        expect(Task.first.taskable_type).to eq('Domain')
      end

      it 'if domains expires date in past' do
        create :domain, expires_at: date_today - 10.days
        Tasks::CreatePaymentTasks.call
        expect(Task.count).to eq(1)
        expect(Task.first.taskable_type).to eq('Domain')
      end
    end

    context 'should not create domain payment task' do
      it 'if domains expires date over than 14 days interval' do
        create :domain, expires_at: date_today + 20.days
        Tasks::CreatePaymentTasks.call
        expect(Task.count).to eq(0)
      end
    end

    context 'should create host account payment task' do
      it 'if host account expires date in 14 days interval' do
        account = create :account
        create :host_account, account: account, expires_at: date_today + 10.days
        Tasks::CreatePaymentTasks.call
        expect(Task.count).to eq(1)
        expect(Task.first.taskable_type).to eq('HostAccount')
      end

      it 'if host account expires date in past' do
        account = create :account
        create :host_account, account: account, expires_at: date_today - 10.days
        Tasks::CreatePaymentTasks.call
        expect(Task.count).to eq(1)
        expect(Task.first.taskable_type).to eq('HostAccount')
      end

      it 'only for active host accounts' do
        account = create :account
        create :host_account, account: account, expires_at: date_today + 10.days
        create :host_account, account: account, expires_at: date_today + 10.days, active: false
        Tasks::CreatePaymentTasks.call
        expect(Task.count).to eq(1)
        expect(Task.first.taskable_type).to eq('HostAccount')
      end
    end

    context 'should not create host account payment task' do
      it 'if host account has parent host account' do
        account = create :account
        create :host_account, account: account,
                              expires_at: date_today + 5.days, parent_host_account_id: 2
        Tasks::CreatePaymentTasks.call
        expect(Task.count).to eq(0)
      end

      it 'if host account expires date over than 14 days interval' do
        account = create :account
        create :host_account, account: account, expires_at: date_today + 20.days
        Tasks::CreatePaymentTasks.call
        expect(Task.count).to eq(0)
      end

      it 'if account is disabled for host payments' do
        account = create :account, enable_host_payments: false
        create :host_account, account: account, expires_at: date_today + 5.days
        Tasks::CreatePaymentTasks.call
        expect(Task.count).to eq(0)
      end
    end
  end
end
