require 'rails_helper'

describe Twitter::Service do
  let(:account) { create(:account, :twitter) }
  let(:service) { Twitter::Service }

  context 'verify token' do
    specify 'success' do
      command = service.new(account)
      allow_any_instance_of(Twitter::REST::Client).to receive(:verify_credentials).and_return(true)
      expect(command.valid_token?(account.token)).to be_truthy
    end

    specify 'fail' do
      command = service.new(account)
      allow_any_instance_of(Twitter::REST::Client).to(
        receive(:verify_credentials).and_raise(Twitter::Error::Unauthorized)
      )
      expect(command.valid_token?(account.token)).to be_falsey
    end
  end
end
