require 'rails_helper'

describe 'Research feed' do
  let(:customer) { create(:customer, :with_active_subscr, :with_topics) }
  let(:fb_account) { create(:account, :with_facebook_page, customer: customer) }
  let(:topic) { customer.topics.first }
  let(:news_1) do
    create(:news, :with_image,
      with_topic: topic,
      created_at: Time.current - 2.days,
      kind: 'research')
  end

  let(:news_2) do
    create(:news, :with_image,
      with_topic: topic,
      created_at: Time.current,
      kind: 'research')
  end

  let(:news_3) do
    create(:news, :with_image,
      with_topic: topic,
      created_at: Time.current,
      kind: 'news')
  end

  before { user_sign_in customer.primary_user }

  skip 'success', :js do
    specify 'reject' do
      news_1
      news_2
      news_3
      visit user_research_magnet_path
      expect(page).to have_content '1 more'
      expect(page).to have_content news_2.title
      expect(page).not_to have_content news_3.title
      click_on 'Reject'
      within '.rejected' do
        expect(page).to have_content news_2.title
      end
      within '.saved' do
        expect(page).not_to have_content news_2.title
      end
    end

    specify 'save' do
      news_1
      news_2
      news_3
      visit user_research_magnet_path
      expect(page).to have_content '1 more'
      expect(page).to have_content news_2.title
      expect(page).not_to have_content news_3.title
      click_on 'Save'
      within '.saved' do
        expect(page).to have_content news_2.title
      end
      within '.rejected' do
        expect(page).not_to have_content news_2.title
      end
    end

    specify 'no saved news' do
      news_1
      visit user_research_magnet_path
      click_on 'Save'
      expect(page).to have_content 'No more'
    end
  end
end
