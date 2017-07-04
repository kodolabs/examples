require 'rails_helper'

feature 'View streams' do
  let!(:customer) { create(:customer, :with_active_subscr) }
  let!(:twitter_account) { create(:account, :twitter, customer: customer) }
  let!(:twitter_page) { create(:page, :twitter, title: 'page title') }
  let!(:source_page) { create :source_page, title: 'test', feed: customer.feeds.first, page: twitter_page }

  let(:fb_account) { create(:account, :facebook, customer: customer) }
  let(:fb_page) { create(:page, :facebook, title: 'page title') }
  let(:fb_source_page) { create :source_page, title: 'test', feed: customer.feeds.first, page: fb_page }

  let(:fb_page2) { create(:page, :facebook) }
  let(:fb_source_page2) do
    create :source_page,
      title: 'Old source page',
      feed: customer.feeds.first,
      page: fb_page2,
      created_at: 10.days.ago
  end

  context 'when user logged in' do
    before { user_sign_in customer.primary_user }

    it "should display feed's posts", :js do
      post = create :post, page: twitter_page
      visit user_social_magnet_path
      expect(page).to have_content post.page.handle
      expect(page).to have_content post.content
    end

    it 'should display message if feed has no posts', :js do
      visit user_social_magnet_path
      expect(page).to have_content 'No posts'
    end

    it 'show share button' do
      twitter_account
      create :post, page: twitter_page
      visit user_social_magnet_path
      expect(page).to have_content 'Share'
      expect(page).to have_content 'Post'
    end

    context 'sort' do
      it "should order feed's posts by recent", :js do
        first_post = create :post, page: twitter_page
        second_post = create :post, page: twitter_page, posted_at: Time.current - 2.hours, uid: '123'
        visit user_social_magnet_path
        expect(page).to have_content first_post.content
        expect(page).to have_content second_post.content
      end

      it "should order feed's posts by most liked", :js do
        first_post = create :post, page: twitter_page, likes_count: 1
        second_post = create :post, page: twitter_page, likes_count: 2, uid: '123'
        visit user_social_magnet_path(order: 'liked')
        expect(page).to have_content second_post.content
        expect(page).to have_content first_post.content
      end

      it "should order feed's posts by most shared", :js do
        first_post = create :post, page: twitter_page, shares_count: 1
        second_post = create :post, page: twitter_page, shares_count: 2, uid: '123'
        visit user_social_magnet_path(order: 'shared')
        expect(page).to have_content second_post.content
        expect(page).to have_content first_post.content
      end

      it 'order posts by source pages created_at, posts posted_at' do
        recent_page = fb_page
        fb_source_page
        old_page = fb_page2
        fb_source_page2

        post1 = create :post, page: recent_page, posted_at: 10.minutes.ago
        post2 = create :post, page: recent_page, posted_at: 20.minutes.ago

        post3 = create :post, page: old_page, posted_at: 1.day.ago
        post4 = create :post, page: old_page, posted_at: 2.days.ago

        visit user_social_magnet_path(order: 'recent_streams')
        1.upto(4) do |i|
          within ".grid-post-item:nth-child(#{i})" do
            content = binding.local_variable_get("post#{i}").content
            expect(page).to have_content(content)
          end
        end
      end
    end

    context 'filter', :js do
      context 'success' do
        specify 'by source page' do
          source_page
          fb_source_page
          twitter_post = create :post, page: twitter_page
          fb_post = create :post, page: fb_page
          visit user_social_magnet_path(filter: fb_page.id)
          expect(page).to have_content fb_post.content
          expect(page).not_to have_content twitter_post.content
        end
      end

      context 'fail' do
        specify 'one source page' do
          source_page
          create :post, page: twitter_page

          visit user_social_magnet_path
          within '.content-magnet-filters' do
            expect(page).not_to have_content 'Filter'
            expect(page).to have_content 'Sort by'
          end
        end
      end
    end

    context 'filter and order', :js do
      specify 'most shared by source page' do
        source_page
        fb_source_page
        twitter_post = create :post, page: twitter_page
        fb_post = create :post, page: fb_page, shares_count: 5
        fb_post2 = create :post, page: fb_page, shares_count: 10

        visit user_social_magnet_path(filter: fb_page.id, order: 'shared')
        within '.grid-post-item:nth-child(1)' do
          expect(page).to have_content fb_post2.content
        end
        within '.grid-post-item:nth-child(2)' do
          expect(page).to have_content fb_post.content
        end
        expect(page).to have_css('.grid-post-item', count: 2)
        expect(page).not_to have_content twitter_post.content
      end
    end
  end
end
