require 'rails_helper'

describe RemoveDemoPostsWorker do
  let(:worker) { RemoveDemoPostsWorker }
  let(:destroy_worker) { DestroyShareWorker }

  let(:share) { create(:share, :demo) }
  let(:share2) { create(:share) }

  specify 'success' do
    share
    share2
    allow(destroy_worker).to receive(:perform_async)
    expect(destroy_worker).to receive(:perform_async).once.with(share.id)
    worker.new.perform
  end
end
