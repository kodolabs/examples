require 'rails_helper'

describe ShareWorker do
  specify 'success' do
    allow_any_instance_of(Shares::Commands::Publish).to receive(:call)
    expect_any_instance_of(Shares::Commands::Publish).to receive(:call).once
    ShareWorker.new.perform(9)
  end
end
