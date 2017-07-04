require 'rails_helper'

feature 'User roles' do
  describe 'account manager' do
    let!(:user) { create :user, role: :account_manager }
    before { user_sign_in user }

    it 'available menu' do
      expect(page).to have_selector('.navigation-menu a:not([href="#"])', count: 2)
      expect(page.find('.navigation-menu li:first')).to have_content I18n.t('clients.title')
      expect(page.find('.navigation-menu li:last')).to have_content I18n.t('campaigns.title')
    end

    it "should can't open hidden sections" do
      [
        domains_path,
        networks_path,
        proxies_path,
        tasks_path,
        users_path,
        host_accounts_path
      ].each do |path|
        visit path

        expect(current_path).to eq root_path
        expect(page).to have_flash I18n.t('notifications.access_denied')
      end
    end

    it 'can open all sections' do
      page.all('.navigation-menu a:not([href="#"])').each do |link|
        link.click
        expect(current_path).to eq link[:href]
        expect(page).to_not have_flash I18n.t('notifications.access_denied')
      end
    end
  end

  describe 'admin' do
    let!(:user) { create :user, role: :admin }
    before { user_sign_in user }

    it 'available menu' do
      expect(page).to have_selector('.navigation-menu a:not([href="#"])', count: 13)

      [
        I18n.t('nav_menu.domains.title'),
        I18n.t('nav_menu.domains.list'),
        I18n.t('nav_menu.domains.new'),
        I18n.t('nav_menu.domains.networks'),
        I18n.t('nav_menu.host_accounts.title'),
        I18n.t('nav_menu.host_accounts.control_panels'),
        I18n.t('nav_menu.host_accounts.host_provider_accounts'),
        I18n.t('nav_menu.host_accounts.registrar_accounts'),
        I18n.t('nav_menu.clients.title'),
        I18n.t('nav_menu.campaigns.title'),
        I18n.t('nav_menu.articles.title'),
        I18n.t('nav_menu.tasks.title'),
        I18n.t('nav_menu.users.title'),
        I18n.t('nav_menu.settings.proxies'),
        I18n.t('nav_menu.settings.title'),
        I18n.t('nav_menu.settings.title')
      ].each do |section|
        expect(page.find('.navigation-menu')).to have_content section
      end
    end

    it 'can open all sections' do
      page.all('.navigation-menu a:not([href="#"])').each do |link|
        link.click
        expect(current_path).to eq link[:href]
        expect(page).to_not have_flash I18n.t('notifications.access_denied')
      end
    end
  end

  describe 'tech' do
    let!(:user) { create :user, role: :tech }
    before { user_sign_in user }

    it 'available menu' do
      expect(page).to have_selector('.navigation-menu a:not([href="#"])', count: 12)

      [
        I18n.t('nav_menu.domains.title'),
        I18n.t('nav_menu.domains.list'),
        I18n.t('nav_menu.domains.new'),
        I18n.t('nav_menu.domains.networks'),
        I18n.t('nav_menu.host_accounts.title'),
        I18n.t('nav_menu.host_accounts.host_provider_accounts'),
        I18n.t('nav_menu.host_accounts.control_panels'),
        I18n.t('nav_menu.host_accounts.registrar_accounts'),
        I18n.t('nav_menu.clients.title'),
        I18n.t('nav_menu.campaigns.title'),
        I18n.t('nav_menu.articles.title'),
        I18n.t('nav_menu.tasks.title'),
        I18n.t('nav_menu.settings.proxies'),
        I18n.t('nav_menu.settings.title'),
        I18n.t('nav_menu.settings.title')
      ].each do |section|
        expect(page.find('.navigation-menu')).to have_content section
      end

      expect(page.find('.navigation-menu')).to_not have_content I18n.t('users.title')
    end

    it "should can't open users section" do
      visit users_path

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end

    it 'can open all sections' do
      page.all('.navigation-menu a:not([href="#"])').each do |link|
        link.click
        expect(current_path).to eq link[:href]
        expect(page).to_not have_flash I18n.t('notifications.access_denied')
      end
    end
  end
end
