require 'rails_helper'

describe SourcePages::Sync do
  context 'success' do
    let(:command) { SourcePages::Sync }
    let(:feed) { create(:feed) }
    let(:create_command) { SourcePages::Create }

    specify 'create source pages' do
      allow_any_instance_of(create_command).to receive(:call)
      expect_any_instance_of(create_command).to receive(:call).once

      command.new(feed_id: feed.id).call
    end
  end
end
