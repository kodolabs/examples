require 'rails_helper'

describe CheckToken::Facebook do
  let(:service) { CheckToken::Facebook }
  let(:account) { create(:account, :facebook) }

  context 'success', :stub_facebook_auth do
    specify 'token is invalid' do
      api_response = {
        'data' => {
          'error' => 'some error'
        }
      }
      allow_any_instance_of(service).to receive(:make_request).and_return(api_response)
      service.new(account).call
      expect(account.active).to be_blank
    end

    specify 'scopes are missed' do
      api_response = {
        'data' => {
          'scopes' => []
        }
      }
      allow_any_instance_of(service).to receive(:make_request).and_return(api_response)
      service.new(account).call
      expect(account.active).to be_blank
    end

    specify 'app was deleted from my apps' do
      exception = Koala::Facebook::AuthenticationError.new(400, 'response_body')
      allow_any_instance_of(service).to receive(:make_request).and_raise(exception)
      service.new(account).call
      expect(account.active).to be_blank
    end
  end

  context 'fail', :stub_facebook_auth do
    specify 'valid token' do
      scopes = Devise.omniauth_configs[:facebook].options[:scope].split(',')
      api_response = {
        'data' => {
          'scopes' => scopes + ['public_profile']
        }
      }
      allow_any_instance_of(service).to receive(:make_request).and_return(api_response)
      service.new(account).call
      expect(account.active).to be_truthy
    end

    specify 'app token is empty' do
      error = 'You must provide an app access token or a user access token'
      exception = Koala::Facebook::ClientError.new(400, error)
      allow_any_instance_of(service).to receive(:make_request).and_raise(exception)
      expect { service.new(account).call }.to raise_error(Koala::Facebook::ClientError)
      expect(account.reload.active).to be_truthy
    end
  end
end
