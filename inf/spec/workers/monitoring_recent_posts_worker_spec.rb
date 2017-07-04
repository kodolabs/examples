require 'rails_helper'

RSpec.describe MonitoringRecentPostsWorker do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:facebook_account) { create(:account, :with_facebook_page, customer: customer) }
  let(:facebook_page) { account.pages.facebook.last }

  context 'success' do
    specify 'crawl posts' do
      facebook_account
      expect(RecentPostsWorker).to receive(:perform_async).once
      MonitoringRecentPostsWorker.new.perform
    end
  end

  context 'fail' do
    let(:external_facebook_page) { create(:page, :facebook) }

    specify 'not owned pages' do
      external_facebook_page
      expect(RecentPostsWorker).not_to receive(:perform_async)
      MonitoringRecentPostsWorker.new.perform
    end
  end
end
