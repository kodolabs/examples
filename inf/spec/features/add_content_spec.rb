require 'rails_helper'

feature 'Add Content Page' do
  let(:customer) { create(:customer, :with_active_subscr, :with_topics) }
  let(:feed) { customer.primary_feed }
  let(:category) { create :category, title: 'Recommendations', topics: customer.topics }
  let(:facebook_page) { create :page, :facebook }
  let(:featured_page) { create :featured_page, page: facebook_page, categories: [category] }

  before do
    user_sign_in customer.primary_user
  end

  specify 'should display pages inside categories' do
    featured_page
    visit user_feeds_path
    expect(page).to have_content category.title
    expect(page).to have_content featured_page.title
    expect(page).to have_content facebook_page.handle
  end

  context 'user' do
    specify 'can add featured page in source list', :js do
      featured_page
      visit user_feeds_path
      within '.streams-connection--recommended' do
        find('.streams-connection__btn').trigger('click')
      end
      sidebar = find('#connected-streams')
      expect(sidebar).to have_content featured_page.title
    end

    specify 'can not add featured page if it in its source list' do
      create :source_page, feed: feed, page: facebook_page
      visit user_feeds_path
      expect(page).not_to have_css('.streams-connection--recommended')
    end
  end
end
