require 'rails_helper'

feature 'Article' do
  let!(:customer) { create(:customer, :with_active_subscr) }
  let!(:facebook_account) { create(:account, :with_facebook_page, customer: customer) }
  let!(:facebook_page) { facebook_account.owned_pages.last }
  let!(:twitter_account) { create(:account, :with_twitter_page, customer: customer) }
  let!(:twitter_page) { twitter_account.owned_pages.last }
  let!(:article) { create(:article, customer: customer, owned_pages: [twitter_page], scheduled_at: 1.day.from_now) }
  before(:all) { Sidekiq::Testing.disable! }
  before do
    allow_any_instance_of(User::BaseController).to(
      receive(:fb_account_options)
      .and_return(SecureRandom.hex(5) => 'Test Ad Account Name')
    )
    user_sign_in(customer.primary_user)
  end

  context 'static', :skip do
    specify 'can be created' do
      click_on 'New Post'
      expect(page).to have_content 'New Post'

      click_on 'Post Now'
      expect(page).to have_content "Message can't be blank"
      expect(page).to have_content 'You must specify at least one page'

      fill_in 'article_content', with: 'Another awesome post'
      find("#targets_#{facebook_page.id}_checked").set(true)
      find("#targets_#{twitter_page.id}_checked").set(true)
      click_on 'Post Now'
      expect(page).to have_flash 'Post was successfully created'
      expect(page).to have_current_path user_schedule_path
    end

    specify 'can be updated', :js do
      visit edit_user_article_path(article)
      expect(page).to have_content 'Post'
      expect(find_field('article_content').value).to eq article.content
      # TODO: check twitter page checked and facebook not
      click_on 'Schedule'
      expect(find('#scheduled-date').value).to(
        eq article.shares.first.scheduled_at.strftime('%d/%m/%Y')
      )

      click_on 'Content'
      fill_in 'article_content', with: 'New content'

      # click_on 'Target'
      # find("#targets_#{facebook_page.id}_checked").set(true)
      # find("#targets_#{twitter_page.id}_checked").set(false)

      click_on 'Schedule'
      click_on 'Schedule Post'
      expect(page).to have_flash 'Post was successfully scheduled'
      expect(page).to have_current_path user_schedule_path

      visit edit_user_article_path(article)
      click_on 'Schedule'
      choose('Post Now')
      click_on 'Post Now'
      expect(page).to have_flash 'Post was successfully updated'
      expect(page).to have_current_path user_schedule_path
    end

    specify 'can be deleted', :js do
      a = create(
        :article,
        customer: customer,
        owned_pages: [facebook_page],
        scheduled_at: 1.day.from_now
      )
      visit edit_user_article_path(a)
      click_on 'Delete'
      expect(page).to have_current_path(edit_user_article_path(a))
      expect(page).not_to have_content 'Delete'
    end
  end

  # TODO: implement after calendar click events fixed
  # context 'dynamic', :js do
  #   before { visit user_schedule_path }
  #   specify 'can be created'
  #   specify 'can be updated'
  # end
end
