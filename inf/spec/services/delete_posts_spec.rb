require 'rails_helper'

RSpec.describe DeleteOutdatedPosts do
  let!(:facebook_page) { create(:page, :facebook, last_crawled_at: Time.current) }
  let!(:first_post) { create(:post, page: facebook_page) }
  let!(:second_post) { create(:post, page: facebook_page, updated_at: Time.current - 1.hour) }

  context 'success' do
    specify 'delete post' do
      allow(DestroyPostWorker).to receive(:perform_async)
      expect(DestroyPostWorker).to receive(:perform_async).with(second_post.id)
      DeleteOutdatedPosts.new(facebook_page).call
    end
  end
end
