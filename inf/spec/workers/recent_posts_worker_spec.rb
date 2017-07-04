require 'rails_helper'

describe RecentPostsWorker do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:facebook_account) { create(:account, :with_facebook_page, customer: customer) }
  let(:facebook_page) { facebook_account.pages.last }

  context 'success' do
    specify 'save page info' do
      facebook_page
      expect_any_instance_of(RecentPosts).to receive(:call)
      RecentPostsWorker.new.perform(facebook_page.id)
    end
  end
end
