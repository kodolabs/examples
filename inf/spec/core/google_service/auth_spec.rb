require 'rails_helper'

describe GoogleService::Auth do
  let(:service) { GoogleService::Auth }
  let(:oauth) { Signet::OAuth2::Client }
  let(:refresh_service) { GoogleService::RefreshToken }

  context 'success' do
    let(:account1) { create(:account, :google) }
    let(:account2) { create(:account, :google, :expired) }

    specify 'create auth' do
      account1
      expect_any_instance_of(refresh_service).not_to receive(:call)
      authorizer = service.new(account1).call
      expect(authorizer.class.name).to eq 'Signet::OAuth2::Client'
      expect(authorizer.access_token).to eq(account1.token)
      expect(authorizer.expires_in).to eq(account1.expires_at.to_i)
    end

    specify 'refresh token' do
      account2
      allow_any_instance_of(refresh_service).to receive(:call)
      expect_any_instance_of(refresh_service).to receive(:call).once
      authorizer = service.new(account2).call
      expect(authorizer.class.name).to eq 'Signet::OAuth2::Client'
      expect(authorizer.access_token).to eq(account2.token)
      expect(authorizer.expires_in).to eq(account2.expires_at.to_i)
    end
  end
end
