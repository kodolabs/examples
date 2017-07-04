require 'rails_helper'

describe MonitoringTokensWorker do
  let(:service) { MonitoringTokensWorker }

  specify 'success' do
    account = create(:account)
    allow(CheckTokenWorker).to receive(:perform_async)
    expect(CheckTokenWorker).to receive(:perform_async).once.with(account.id)
    service.new.perform
  end
end
