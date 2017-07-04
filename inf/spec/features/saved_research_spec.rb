require 'rails_helper'

describe 'Saved research page' do
  let!(:customer) { create(:customer, :with_active_subscr, :with_topics) }
  let!(:fb_account) { create(:account, :with_facebook_page, customer: customer) }
  let!(:news) do
    create(:news, :with_image, with_topic: topic, created_at: Time.current, kind: :research)
  end
  let!(:topic) { customer.topics.first }
  let!(:fb_account) { create(:account, :with_facebook_page, customer: customer) }

  before { user_sign_in customer.primary_user }

  context 'no posts', :js do
    specify 'message displayed' do
      visit user_saved_research_path
      expect(page).to have_content('No posts')
    end
  end

  context 'posts persist', :js do
    let!(:resolved_item) { create(:resolved_item, customer: customer, decideable: news, decision: :saved) }

    specify 'share buttons displayed' do
      visit user_saved_research_path
      expect(page).to have_selector('button.share')
      expect(page).to have_selector('button.auto')
      expect(page).to have_selector('button.save')
    end
  end
end
