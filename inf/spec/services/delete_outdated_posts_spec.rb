require 'rails_helper'

describe DeleteOutdatedPosts do
  let(:fb_account) { create(:account, :facebook, :with_facebook_page) }
  let(:fb_page1) { fb_account.pages.last }
  let(:fb_page2) { create(:page, :facebook) }
  let(:twitter_page) { create(:page, :twitter) }

  let(:post1) { create(:post, page: fb_page1, updated_at: 2.days.ago) }
  let(:post2) { create(:post, page: fb_page2, updated_at: 2.days.ago) }
  let(:post3) { create(:post, page: twitter_page, updated_at: 2.days.ago) }

  let(:service) { DeleteOutdatedPosts }
  let(:worker) { DestroyPostWorker }

  context 'success' do
    specify 'twitter' do
      post3
      allow(worker).to receive(:perform_async)
      expect(worker).to receive(:perform_async).once.with(post3.id)
      service.new(twitter_page).call
    end

    specify 'fb not owned' do
      post2
      allow(worker).to receive(:perform_async)
      expect(worker).to receive(:perform_async).once.with(post2.id)
      service.new(fb_page2).call
    end
  end

  context 'fail' do
    specify 'facebook owned' do
      post1
      expect(worker).not_to receive(:perform_async)
      service.new(fb_page1).call
    end
  end
end
