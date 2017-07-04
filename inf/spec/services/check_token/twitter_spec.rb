require 'rails_helper'

describe CheckToken::Twitter do
  let(:account) { create(:account, :twitter) }
  let(:service) { CheckToken::Twitter }

  specify 'success' do
    account
    allow_any_instance_of(Twitter::Service).to receive(:valid_token?).and_return(false)
    service.new(account).call
    expect(account.reload.active).to be_blank
  end

  specify 'fail' do
    account
    allow_any_instance_of(Twitter::Service).to receive(:valid_token?).and_return(true)
    service.new(account).call
    expect(account.reload.active).to eq(true)
  end
end
