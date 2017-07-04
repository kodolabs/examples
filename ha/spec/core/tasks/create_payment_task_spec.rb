require 'rails_helper'

describe Tasks::CreatePaymentTask do
  let(:date_today) { Time.zone.now }

  context 'should create domain payment task' do
    it 'if task not exist' do
      domain = create :domain, expires_at: date_today + 10.days
      Tasks::CreatePaymentTask.new(domain).call
      expect(Task.payment.count).to eq 1
      expect(Task.first.taskable_type).to eq 'Domain'
    end
  end

  context 'should not create domain payment task' do
    it 'if task with signature is exist' do
      expires_date = (date_today - 10.days)
      domain = create :domain, expires_at: expires_date
      signature = "expiration:domain_#{domain.id}:#{expires_date.strftime('%Y%m%d')}"
      create :task, :pending, :payment, signature: signature, taskable: domain
      Tasks::CreatePaymentTask.new(domain).call
      expect(Task.payment.count).to eq 1
    end
  end

  context 'should create host account payment task' do
    it 'if task not exist' do
      host_account = create :host_account, expires_at: date_today + 10.days
      Tasks::CreatePaymentTask.new(host_account).call
      expect(Task.payment.count).to eq 1
      expect(Task.first.taskable_type).to eq 'HostAccount'
    end
  end

  context 'should not create host account payment task' do
    it 'if task with signature is exist' do
      expires_date = (date_today - 10.days)
      host_account = create :host_account, expires_at: expires_date
      signature = "expiration:host_account_#{host_account.id}:#{expires_date.strftime('%Y%m%d')}"
      create :task, :pending, :payment, signature: signature, taskable: host_account
      Tasks::CreatePaymentTask.new(host_account).call
      expect(Task.payment.count).to eq 1
    end
  end
end
