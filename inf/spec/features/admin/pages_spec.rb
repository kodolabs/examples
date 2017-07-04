require 'rails_helper'

feature 'Pages' do
  let(:admin) { create :admin }
  let!(:page1) { create :page, :facebook, title: 'Johndoe', handle: 'thedoe', uid: '123456' }
  let!(:page2) { create :page, :facebook, title: 'Janesmith', handle: 'thesmith', uid: '654321' }

  context 'when admin logged in' do
    before { admin_sign_in admin }

    it 'can see list of all pages' do
      visit admin_pages_path

      expect(page).to have_content 'Sources'

      expect(page).to have_content page1.title
      expect(page).to have_content page2.title
      expect(page).to have_button 'Update'
    end

    it 'can find page by title' do
      visit admin_pages_path
      fill_in 'Search', with: page1.title
      click_on 'Search'
      expect(page).to have_content page1.title
      expect(page).not_to have_content page2.title
    end

    it 'can find page by part of title' do
      visit admin_pages_path
      fill_in 'Search', with: 'John'
      click_on 'Search'
      expect(page).to have_content page1.title
      expect(page).not_to have_content page2.title
    end

    it 'can find page by handle' do
      visit admin_pages_path
      fill_in 'Search', with: page2.handle
      click_on 'Search'
      expect(page).to have_content page2.title
      expect(page).not_to have_content page1.title
    end

    it 'can find page by part of handle' do
      visit admin_pages_path
      fill_in 'Search', with: 'thesm'
      click_on 'Search'
      expect(page).to have_content page2.title
      expect(page).not_to have_content page1.title
    end

    it 'can find page by uid' do
      visit admin_pages_path
      fill_in 'Search', with: page1.uid
      click_on 'Search'
      expect(page).to have_content page1.title
      expect(page).not_to have_content page2.title
    end

    it 'can find page by part of uid' do
      visit admin_pages_path
      fill_in 'Search', with: '654'
      click_on 'Search'
      expect(page).to have_content page2.title
      expect(page).not_to have_content page1.title
    end
  end
end
