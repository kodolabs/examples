require 'rails_helper'

describe Pages::Create::Base do
  let(:service) { Pages::Create::Twitter }
  specify 'success' do
    allow_any_instance_of(service).to receive(:call)
    expect_any_instance_of(service).to receive(:call).once
    Pages::Create::Base.new(123).call
  end
end
