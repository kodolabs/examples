require 'rails_helper'

describe DestroyPostWorker do
  let(:post) { create(:post) }

  specify 'success' do
    Sidekiq::Testing.inline!
    allow_any_instance_of(Posts::Destroy).to receive(:call)
    expect_any_instance_of(Posts::Destroy).to receive(:call).once
    DestroyPostWorker.perform_async(post.id)
  end
end
