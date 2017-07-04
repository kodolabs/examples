require 'rails_helper'

feature 'Facebook Analysis' do
  let(:customer) { create(:customer, :with_active_subscr) }

  before do
    Sidekiq::Testing.inline!
    user_sign_in customer.primary_user
  end

  context 'success' do
    before do
      account = create :account, :twitter, :with_twitter_page, :with_twitter_posts, customer: customer
      twitter_page = account.pages.twitter.first
      @twitter_post = twitter_page.posts.first
    end

    it 'show recent posts' do
      visit user_twitter_analytics_path
      expect(page).to have_content @twitter_post.likes_count
      expect(page).to have_content @twitter_post.shares_count
    end
  end

  context 'fail' do
    let(:message) { 'You have no connected Twitter accounts.' }

    it 'no twitter account and page' do
      visit user_twitter_analytics_path
      expect(page).to have_content message
    end

    it 'no recent posts' do
      create :account, :twitter, :with_twitter_page, customer: customer
      visit user_twitter_analytics_path
      expect(page).to have_content 'No posts were found in last 30 days'
    end
  end
end
