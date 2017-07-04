require 'rails_helper'

describe CheckTokenWorker do
  let(:service) { CheckTokenWorker }
  let(:command) { CheckToken::Base }

  specify 'success' do
    account_id = 123
    allow_any_instance_of(command).to receive(:call)
    expect_any_instance_of(command).to receive(:call).once
    service.new.perform(account_id)
  end
end
