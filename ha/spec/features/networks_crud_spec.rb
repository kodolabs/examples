require 'rails_helper'

feature 'Networks CRUD' do
  before do
    user_sign_in
  end

  describe 'create' do
    it 'should create new network' do
      visit new_network_path

      fill_in 'network_title', with: 'Test network'
      fill_in 'network_color', with: '#121212'

      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.network_created')
      expect(page).to have_content 'Test network'
    end

    it 'invalid form' do
      visit new_network_path

      click_button 'Create'
      expect(page).to have_content "can't be blank"
      expect(page).to have_selector('.field_with_errors', count: 2)
    end
  end

  describe 'edit' do
    before do
      network = create :network, title: 'Created network'
      visit edit_network_path(network)
    end

    it 'success edit' do
      fill_in 'network_title', with: 'Test network'

      click_button 'Update'
      expect(page).to have_flash I18n.t('notifications.network_updated')
      expect(page).to have_content 'Test network'
    end

    it 'invalid form' do
      fill_in 'network_title', with: ''

      click_button 'Update'
      expect(page).to have_content "can't be blank"
      expect(page).to have_selector('.field_with_errors', count: 1)
    end
  end

  describe 'destroy' do
    it 'success' do
      network = create :network, title: 'Created network'

      visit edit_network_path(network)

      click_link 'Delete'
      expect(page).to have_flash I18n.t('notifications.network_deleted')
      expect(page).to_not have_content 'Test network'
    end
  end
end
