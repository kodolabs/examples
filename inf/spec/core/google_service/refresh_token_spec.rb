require 'rails_helper'

describe GoogleService::RefreshToken do
  let(:account) { create(:account, :google, :expired) }
  let(:service) { GoogleService::RefreshToken }

  context 'success' do
    specify 'refresh' do
      token = 'aaa'
      expires_in = 3600
      body = {
        access_token: token,
        expires_in: expires_in
      }

      params = {
        client_id: ENV['GOOGLE_CLIENT_ID'],
        client_secret: ENV['GOOGLE_CLIENT_SECRET'],
        refresh_token: account.refresh_token,
        grant_type: 'refresh_token'
      }

      stub_request(:post, 'https://www.googleapis.com/oauth2/v4/token')
        .with(body: params)
        .to_return(status: 200, body: body.to_json)

      service.new(account).call
      expires_at = Time.zone.now + expires_in
      expect(account.expires_at).to be_within(1.second).of expires_at
      expect(account.token).to eq token
    end
  end
end
