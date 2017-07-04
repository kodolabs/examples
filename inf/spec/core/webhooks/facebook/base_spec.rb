require 'rails_helper'
describe Webhooks::Facebook::Base do
  let(:service) { Webhooks::Facebook::Base }
  let(:page_service) { Webhooks::Facebook::Page::Base }

  specify 'success' do
    valid_params = { 'object' => 'page', 'entry' => ['a'] }
    allow_any_instance_of(page_service).to receive(:call)
    expect_any_instance_of(page_service).to receive(:call).once
    service.new(valid_params).call
  end

  specify 'fail' do
    invalid_params = { 'object' => 'payment' }
    expect_any_instance_of(page_service).not_to receive(:call).once
    service.new(invalid_params).call
  end
end
