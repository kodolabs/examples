require 'rails_helper'

feature 'MSM page' do
  let!(:customer) { create(:customer, :with_active_subscr) }
  let!(:facebook_account) { create(:account, :facebook, :with_facebook_page, customer: customer) }
  let!(:facebook_page) { facebook_account.pages.first }

  context 'when user logged in' do
    before { user_sign_in customer.primary_user }

    it "should display feed's posts", :js do
      post = create :post, page: facebook_page, content: 'Awesome #tag'
      visit user_my_feeds_path
      expect(page).to have_content post.page.handle
      expect(page).to have_content post.content
      expect(page).to have_css 'span.post-hashtag', text: '#tag'
    end

    it 'should display message if feed has no posts', :js do
      visit user_my_feeds_path
      expect(page).to have_content 'No posts'
    end

    it "should order feed's posts by recent", :js do
      first_post = create :post, page: facebook_page
      second_post = create :post, page: facebook_page, posted_at: Time.current - 2.hours, uid: '123'
      visit user_my_feeds_path
      expect(page).to have_content first_post.content
      expect(page).to have_content second_post.content
    end

    it "should order feed's posts by most liked", :js do
      first_post = create :post, page: facebook_page, likes_count: 1
      second_post = create :post, page: facebook_page, likes_count: 2, uid: '123'
      visit user_my_feeds_path(order: 'liked')
      expect(page).to have_content second_post.content
      expect(page).to have_content first_post.content
    end

    it "should order feed's posts by most shared", :js do
      first_post = create :post, page: facebook_page, shares_count: 1
      second_post = create :post, page: facebook_page, shares_count: 2, uid: '123'
      visit user_my_feeds_path(order: 'shared')
      expect(page).to have_content second_post.content
      expect(page).to have_content first_post.content
    end
  end
end
