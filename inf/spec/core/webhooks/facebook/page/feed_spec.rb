require 'rails_helper'

describe Webhooks::Facebook::Page::Feed do
  let(:service) { Webhooks::Facebook::Page::Feed }
  let(:page) { create(:page, :facebook) }
  let(:post) { create(:post, page: page) }
  let(:publication) { create(:publication, uid: post.uid) }

  context 'success' do
    specify 'delete posts' do
      post
      value = { 'item' => 'post',  'verb' => 'remove', 'post_id' => post.uid }
      expect(DestroyPostWorker).to receive(:perform_async).once.with(post.id)
      service.new(value).call
    end

    specify 'update video post' do
      post
      publication
      value = { 'item' => 'video', 'verb' => 'add', 'post_id' => post.uid, 'sender_id' => page.uid }
      allow_any_instance_of(RecentPostsWorker).to receive(:perform)
      allow_any_instance_of(UpdatePublication).to receive(:call)

      expect_any_instance_of(RecentPostsWorker).to receive(:perform).once
      expect_any_instance_of(UpdatePublication).to receive(:call).once

      service.new(value).call
    end
  end
end
