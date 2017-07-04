require 'rails_helper'

feature 'Facebook Analysis' do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:facebook_account) { create(:account, :facebook, :with_facebook_page, customer: customer) }
  let(:facebook_page) { facebook_account.pages.facebook.first }
  let(:post) { create(:post, page: facebook_page) }
  let(:empty_post) { create(:post, page: facebook_page, content: nil) }

  before do
    Timecop.freeze Time.zone.local(2016, 10, 12, 12, 20, 0)
    Sidekiq::Testing.inline!
    user_sign_in customer.primary_user
  end

  after { Timecop.return }

  context 'success' do
    before { facebook_account }
    it 'show pages list' do
      visit user_facebook_analytics_path
      expect(page).to have_select facebook_page.title
    end

    it 'show recent posts' do
      post
      visit user_facebook_analytics_path(facebook_page)

      expect(page).to have_content post.comments_count
      expect(page).to have_content post.likes_count
      expect(page).to have_content post.shares_count
    end

    it 'show placeholder for empty post' do
      empty_post
      visit user_facebook_analytics_path(facebook_page)
      expect(page).to have_css(".post-placeholder[style*='app/fb-placeholder']")
    end
  end

  context 'fail' do
    let(:invalid_account) { create(:account, :facebook, customer: customer) }
    let(:message) { 'You have no connected Facebook accounts' }

    it 'no facebook account' do
      visit user_facebook_analytics_path
      expect(page).to have_content message
    end

    it 'no facebook pages' do
      invalid_account
      visit user_facebook_analytics_path
      expect(page).to have_content message
    end

    it 'no recent posts' do
      facebook_page
      visit user_facebook_analytics_path(facebook_page)
      expect(page).to have_content 'No posts were found in last 30 days'
    end
  end
end
