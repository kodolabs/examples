require 'rails_helper'

feature 'Category' do
  let(:admin) { create :admin }

  context 'when admin logged in', :js do
    before { admin_sign_in admin }

    it 'can create a new category' do
      visit new_admin_category_path
      fill_in 'Title', with: 'Test'
      click_on 'Create'
      expect(page).to have_content 'Category successfully created'
    end

    it 'can update category' do
      category = create :category
      visit edit_admin_category_path(category)
      fill_in 'Title', with: 'New category title'
      click_on 'Update'
      expect(page).to have_content 'Category successfully updated'
      expect(page).to have_content 'New category title'
    end

    it 'can delete category' do
      create :category
      visit new_admin_category_path
      page.find('.delete-link').click
      expect(page).to have_content 'Category successfully deleted'
    end

    it 'should display by positions' do
      category2 = create :category
      category1 = create :category
      visit new_admin_category_path
      categories = page.all('.category')
      expect(categories[0]).to have_content category2.title
      expect(categories[1]).to have_content category1.title
    end
  end
end
