require 'rails_helper'

describe Webhooks::Facebook::Service do
  context 'success' do
    let(:service) { Webhooks::Facebook::Service }

    specify 'valid integrity' do
      headers = { 'X-Hub-Signature' => 'aaa&sha1=83e77889b9df2b0d4df846aaa776aeb4ed0c3c40' }
      body = 'sss'
      expect(service.new.valid_integrity?(body, headers)).to be_truthy
    end
  end
end
