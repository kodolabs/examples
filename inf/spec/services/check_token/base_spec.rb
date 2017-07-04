require 'rails_helper'

describe CheckToken::Base do
  let(:service) { CheckToken::Base }

  context 'success' do
    let(:command) { CheckToken::Facebook }
    specify 'facebook' do
      account = create(:account, :facebook)
      allow_any_instance_of(command).to receive(:call)
      expect_any_instance_of(command).to receive(:call).once
      service.new(account.id).call
    end
  end
end
