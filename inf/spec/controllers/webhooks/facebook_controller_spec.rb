require 'rails_helper'

describe Webhooks::FacebookController, type: :controller do
  context 'verification' do
    let(:env_token) { ENV['FACEBOOK_WEBHOOKS_TOKEN'] }
    specify 'success' do
      token = Digest::SHA1.hexdigest(env_token)
      p = {
        'hub.mode' => 'subscribe',
        'hub.verify_token' => token,
        'hub.challenge' => 'aa'
      }
      get :verify, params: p
      expect(response.body).to eq 'aa'
    end

    specify 'fail' do
      get :verify
      expect(response.status).to eq(400)
    end
  end

  context 'updates' do
    let(:api_service) { Webhooks::Facebook::Service }
    let(:service) { Webhooks::Facebook::Base }
    specify 'process' do
      allow_any_instance_of(service).to receive(:call)
      expect_any_instance_of(service).to receive(:call).once
      allow_any_instance_of(api_service).to receive(:valid_integrity?).and_return(true)
      expect_any_instance_of(api_service).to receive(:valid_integrity?).once
      post :updates
      expect(response.status).to eq(200)
    end
  end
end
