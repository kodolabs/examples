require 'rails_helper'

describe PostStatsWorker do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:account) { create(:account, :with_twitter_page, customer: customer) }
  let(:page) { account.pages.twitter.first }

  context 'success' do
    specify 'fetch stats' do
      page
      account
      options = { 'save_history' => true }
      expect(PostsWorker).to receive(:perform_async).once.with(page.id, options)
      PostStatsWorker.new.perform
    end
  end
end
