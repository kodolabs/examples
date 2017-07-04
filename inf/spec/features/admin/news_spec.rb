require 'rails_helper'

feature 'News spec' do
  let!(:admin) { create :admin }
  let!(:news_1) { create :news, title: 'aab', kind: :research }
  let!(:news_2) { create :news, title: 'abb', kind: :news }

  before do
    admin_sign_in admin
  end

  context 'kind selector' do
    it 'setted with kind value' do
      visit edit_admin_news_path(news_1)
      kind = find(:radio_button, 'news[kind]', checked: true).value
      expect(kind).to eq('research')

      visit edit_admin_news_path(news_2)
      kind = find(:radio_button, 'news[kind]', checked: true).value
      expect(kind).to eq('news')
    end
  end

  context 'filtering' do
    it 'displays all news on all tab' do
      visit admin_news_index_path
      expect(page).to have_content(news_1.title)
      expect(page).to have_content(news_2.title)
    end

    it 'displays only research news on research tab' do
      visit admin_news_index_path(kind: :research)
      expect(page).to have_content(news_1.title)
      expect(page).to_not have_content(news_2.title)
    end

    it 'dont displays research on news tab' do
      visit admin_news_index_path(kind: :news)
      expect(page).to_not have_content(news_1.title)
      expect(page).to have_content(news_2.title)
    end

    it 'performs search only within own tab' do
      visit admin_news_index_path
      fill_in 'Search', with: 'a'
      click_on 'Search'
      expect(page).to have_content(news_1.title)
      expect(page).to have_content(news_2.title)

      visit admin_news_index_path(kind: :news)
      fill_in 'Search', with: 'a'
      click_on 'Search'
      expect(page).to_not have_content(news_1.title)
      expect(page).to have_content(news_2.title)

      visit admin_news_index_path(kind: :research)
      fill_in 'Search', with: 'a'
      click_on 'Search'
      expect(page).to have_content(news_1.title)
      expect(page).to_not have_content(news_2.title)
    end
  end
end
