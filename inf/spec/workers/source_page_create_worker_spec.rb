require 'rails_helper'

describe SourcePageCreateWorker do
  context 'success' do
    let(:worker) { SourcePageCreateWorker }
    let(:service) { SourcePages::Sync }

    specify 'run sync' do
      allow_any_instance_of(service).to receive(:call)
      expect_any_instance_of(service).to receive(:call).once

      options = { a: 1 }
      worker.new.perform(options)
    end
  end
end
