require 'rails_helper'

describe CheckInvalidAccountsWorker do
  context 'success' do
    let(:valid_account) { create(:account) }
    let(:invalid_connected_account) { create(:account, :with_invalid_token) }
    let(:invalid_not_connected_account) { create(:account, :with_invalid_token, customer: nil) }
    let(:invalid_connected_account_new) { create(:account, :with_invalid_token, :nearly_notified) }
    let(:invalid_connected_account_old) { create(:account, :with_invalid_token, :old_notified) }

    let(:worker) { CheckInvalidAccountsWorker }
    let(:email_worker) { InvalidAccountEmailWorker }

    specify 'send email' do
      valid_account
      invalid_connected_account
      invalid_not_connected_account
      invalid_connected_account_new
      invalid_connected_account_old
      allow(email_worker).to receive(:perform_async)
      expect(email_worker).to receive(:perform_async).with(invalid_connected_account.customer_id).once
      expect(email_worker).to receive(:perform_async).with(invalid_connected_account_old.customer_id).once

      worker.new.perform
    end
  end
end
