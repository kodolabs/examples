require 'rails_helper'

RSpec.describe SavePageInfo do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:twitter_account) { create(:account, :with_twitter_page, customer: customer) }
  let(:facebook_account) { create(:account, :with_facebook_page, customer: customer) }

  let(:facebook_page) { facebook_account.pages.first }
  let(:twitter_page) { twitter_account.pages.twitter.last }

  context 'success' do
    before do
      facebook_page
      twitter_page
    end

    specify 'twitter' do
      expect_any_instance_of(Twitter::SavePageInfo).to receive(:call)
      SavePageInfo.new(twitter_page).call
    end

    specify 'facebook' do
      expect_any_instance_of(Facebook::SavePageInfo).to receive(:call)
      SavePageInfo.new(facebook_page).call
    end
  end

  context 'fail' do
    specify 'empty' do
      expect_any_instance_of(Facebook::SavePageInfo).not_to receive(:call)
      SavePageInfo.new(nil).call
    end
  end
end
