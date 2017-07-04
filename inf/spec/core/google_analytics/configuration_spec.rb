require 'rails_helper'

describe GoogleAnalytics::Configuration do
  let(:service) { GoogleAnalytics::Configuration }
  let(:request_service) { GoogleAnalytics::AccountSummary }

  context 'success' do
    specify 'fetch data' do
      account = build(:account)
      allow_any_instance_of(request_service).to receive(:call)
      allow_any_instance_of(request_service).to receive(:accounts) { 'acc' }
      allow_any_instance_of(request_service).to receive(:views) { 'vv' }

      expect_any_instance_of(request_service).to receive(:call).once
      command = service.new(account)
      command.call
      expect(command.accounts).to eq 'acc'
      expect(command.views).to eq 'vv'
    end
  end
end
