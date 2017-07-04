require 'google/apis/analytics_v3'
require 'rails_helper'

describe GoogleAnalytics::AccountSummary do
  let(:service) { GoogleAnalytics::AccountSummary }
  let(:auth_service) { GoogleService::Auth }
  let(:api_service) { Google::Apis::AnalyticsV3::AnalyticsService }
  context 'success' do
    specify 'fetch data' do
      account = build(:account)
      allow_any_instance_of(auth_service).to receive(:call)
      expect_any_instance_of(auth_service).to receive(:call).once

      allow_any_instance_of(api_service).to receive('authorization=')
      expect_any_instance_of(api_service).to receive('authorization=').once

      command = service.new(account)
      command.call
    end
  end
end
