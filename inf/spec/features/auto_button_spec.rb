require 'rails_helper'

feature 'Auto button' do
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:user) { customer.primary_user }
  let(:fb_account) { create(:account, :facebook, :with_facebook_page, customer: customer) }
  let(:fb_page) { fb_account.pages.last }
  let(:feed) { customer.feeds.first }
  let(:fb_source_page) { create :source_page, title: 'test', feed: feed, page: fb_page }
  let(:owned_page) { fb_account.owned_pages.first }
  let(:post) { facebook_page.posts.last }

  before(:each) { user_sign_in user }

  context 'on page refresh' do
    context 'view streams' do
      let(:post) { create :post, page: fb_page, content: 'Awesome post' }

      specify 'enabled' do
        fb_source_page
        post_now_share = create :share, shareable: post, auto: true, customer: customer
        post_now_share.owned_pages << owned_page
        visit user_social_magnet_path
        expect(page).to have_content post.content
        button = page.find('.auto')
        expect(button[:disabled]).to be_blank
        expect(button[:class]).not_to include 'half-opacity'
      end

      specify 'disabled' do
        fb_source_page
        post_now_share = create :share, shareable: post, auto: false, customer: customer
        post_now_share.owned_pages << owned_page
        visit user_social_magnet_path
        expect(page).to have_content post.content
        button = page.find('.auto')
        expect(button[:disabled]).to eq 'disabled'
        expect(button[:class]).to include 'half-opacity'
      end
    end
  end
end
