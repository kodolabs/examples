require 'rails_helper'

feature 'Proxies' do
  let!(:proxy1) { create :proxy, address: '127.0.0.1' }
  let!(:proxy2) { create :proxy, address: '192.168.0.1' }

  before do
    user_sign_in
    visit proxies_path
    @proxies = page.all('.proxy')
  end

  describe 'list' do
    it 'should show proxies in order' do
      expect(@proxies[0]).to have_content proxy1.address
      expect(@proxies[1]).to have_content proxy2.address
    end

    it 'should delete proxy from table' do
      visit edit_proxy_path proxy1
      click_link I18n.t('button.delete')
      expect(page).to have_flash I18n.t('notifications.proxy_deleted')
    end
  end

  describe 'add page' do
    before { visit new_proxy_path }

    it 'should create proxy' do
      fill_in 'Address', with: '255.255.255.255'
      fill_in 'Port', with: '80'
      find('#proxy_is_https').set(true)
      fill_in 'Login', with: 'Login'
      fill_in 'Password', with: 'Password'
      click_button I18n.t('button.create')
      expect(page).to have_flash I18n.t('notifications.proxy_created')
    end
  end

  describe 'edit page' do
    before { visit edit_proxy_path proxy1 }

    it 'can update proxy' do
      fill_in 'Address', with: '255.255.266.266'
      fill_in 'Port', with: '80'
      find('#proxy_is_https').set(true)
      fill_in 'Login', with: 'Login'
      fill_in 'Password', with: 'Password'
      click_button I18n.t('button.update')
      expect(page).to have_flash I18n.t('notifications.proxy_updated')
    end
  end
end
