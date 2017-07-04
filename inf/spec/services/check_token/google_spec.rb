require 'rails_helper'
require 'google/apis/oauth2_v2'

describe CheckToken::Google do
  let(:account) { create(:account, :google) }
  let(:service) { CheckToken::Google }
  let(:api_service) { Google::Apis::Core::BaseService }
  let(:refresh_service) { GoogleService::RefreshToken }
  let(:account2) { create(:account, :google, :expired) }

  context 'success' do
    specify 'invalid token' do
      expect_any_instance_of(refresh_service).not_to receive(:call)
      stub_request(:post, 'https://www.googleapis.com/oauth2/v2/tokeninfo')
        .to_return(
          status: 400,
          body: { error_description: 'aa ' }.to_json,
          headers:  { 'Content-Type' => 'application/json' }
        )
      service.new(account).call
      expect(account.reload.active).to be_blank
    end

    specify 'refresh token' do
      stub_request(:post, 'https://www.googleapis.com/oauth2/v2/tokeninfo')
        .to_return(
          status: 400,
          body: { error_description: 'aa ' }.to_json,
          headers:  { 'Content-Type' => 'application/json' }
        )
      account2
      allow_any_instance_of(refresh_service).to receive(:call)
      expect_any_instance_of(refresh_service).to receive(:call).once

      service.new(account2).call
      expect(account2.reload.active).to be_blank
    end
  end
end
