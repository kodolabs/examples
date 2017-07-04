require 'rails_helper'

describe CheckToken::Linkedin do
  let(:account) { create(:account, :linkedin) }
  let(:service) { CheckToken::Linkedin }
  let(:api_service) { Linkedin::Pages }
  let(:api_instance) { api_service.new(account.token) }

  specify 'success' do
    account
    allow(api_service).to receive(:new).with(account.token).and_return(api_instance)
    expect(api_service).to receive(:new).with(account.token).once
    allow(api_instance).to receive(:valid_token?).and_return(false)

    service.new(account).call
    expect(account.reload.active).to be_blank
  end

  specify 'fail' do
    account
    allow(api_service).to receive(:new).with(account.token).once.and_return(api_instance)
    expect(api_service).to receive(:new).with(account.token).once
    expect(api_service).not_to receive(:new).with(account)
    allow(api_instance).to receive(:valid_token?).and_return(true)

    service.new(account).call
    expect(account.reload.active).to eq(true)
  end
end
