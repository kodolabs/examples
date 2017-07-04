require 'rails_helper'

describe Omniauth::Facebook do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:facebook_account) { create(:account, :facebook, customer: customer) }
  let(:service) { Omniauth::Facebook }
  let(:connect_service) { Accounts::Connect }

  context 'success' do
    let(:params) do
      {
        'omniauth.auth' => {
          provider: 'facebook',
          uid: '123545',
          credentials: {
            token: '123',
            expires_at: nil
          },
          info: {
            name: 'Some name'
          }
        }
      }
    end

    before do
      allow_any_instance_of(Facebook::AdsAccountsService).to(
        receive(:update).and_return(true)
      )
    end

    specify 'create facebook account' do
      facebook_account

      request = double(:request)
      expect(request).to receive(:env) { params.with_indifferent_access }
      expect { service.new(user, request).call }.to change(Account, :count).by(1)
    end

    specify 'connect account' do
      request = double(:request)
      expect(request).to receive(:env) { params.with_indifferent_access }
      allow_any_instance_of(connect_service).to receive(:query)
      expect_any_instance_of(connect_service).to receive(:query).once
      service.new(user, request).call
    end
  end
end
