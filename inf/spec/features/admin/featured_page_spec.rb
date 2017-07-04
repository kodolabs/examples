require 'rails_helper'

feature 'Featured Page' do
  let!(:admin) { create :admin }
  let!(:category) { create :category, title: 'Recommendations' }
  let(:page1) { create(:page) }
  let(:present_command) { SourcePage::Present }
  let(:fetch_command) { Page::FindOrCreateAndFetch }
  context 'by logged in admin' do
    before do
      Timecop.freeze Time.zone.local(2016, 10, 7, 12, 20, 0)
      admin_sign_in admin
    end

    after { Timecop.return }

    it 'should be created for twitter source with handle' do
      visit new_admin_featured_page_path
      fill_in 'Title', with: 'Twitter user'
      select category.title, from: 'create_featured_page_category_ids'
      select 'twitter', from: 'create_featured_page_provider'
      choose '@handle'
      fill_in 'Handle', with: 'sstephenson'
      allow_any_instance_of(present_command).to receive(:call).and_return(true)
      allow_any_instance_of(fetch_command).to receive(:call).and_return(page1)
      expect_any_instance_of(fetch_command).to receive(:call).once
      click_on 'Create'
      expect(page).to have_flash 'Featured Source successfully created'
    end

    it 'should be created for twitter source with hashtag' do
      visit new_admin_featured_page_path
      fill_in 'Title', with: 'Twitter page'
      select category.title, from: 'create_featured_page_category_ids'
      select 'twitter', from: 'create_featured_page_provider'
      choose '#hashtag'
      fill_in 'Handle', with: 'SMWLDN'
      allow_any_instance_of(present_command).to receive(:call).and_return(true)
      allow_any_instance_of(fetch_command).to receive(:call).and_return(page1)
      expect_any_instance_of(fetch_command).to receive(:call).once
      click_on 'Create'
      expect(page).to have_flash 'Featured Source successfully created'
    end

    it 'should be edited' do
      featured_page = create :featured_page, categories: [category]
      visit edit_admin_featured_page_path(featured_page)
      fill_in 'Title', with: 'New title'
      select category.title, from: 'update_featured_page_category_ids'
      click_on 'Update'
      expect(page).to have_flash 'Featured Source successfully updated'
      expect(page).to have_content 'New title'
    end

    it 'should be deleted' do
      create :featured_page, categories: [category]
      visit admin_featured_pages_path
      page.find('.delete-link').click
      expect(page).to have_flash 'Featured Source successfully deleted'
    end
  end
end
