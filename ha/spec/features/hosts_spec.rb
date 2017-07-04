require 'rails_helper'
include ApplicationHelper

feature 'Hosts' do
  let!(:domain) { create :domain }
  let!(:blog) { create :blog }

  before do
    user_sign_in
  end

  def check_blog_history
    host_account = create :host_account, login: 'test', ip: '127.0.0.1'
    active_host = create :host, active: true, domain: domain, blog: blog, host_account: host_account
    inactive_host = create :host, active: false, blog: blog
    visit domain_hosts_path(domain)
    expect(find('.history-table')).to have_content inactive_host.domain.name
    expect(find('.history-table')).to have_content active_host.domain.name
    expect(find('.history-table')).to have_content host_account.login
    expect(find('.history-table')).to have_content host_account.ip
    expect(find('.history-table')).to have_content host_account.account.label
  end

  def check_domain_history
    other_domain = create :domain
    create :host, active: false, domain: domain, blog: blog
    create :host, active: true, blog: blog, domain: other_domain
    other_host = create :host, active: true, blog: blog

    visit domain_hosts_path(domain)
    expect(find('.history-table')).to have_content other_domain.name
    expect(find('.history-table')).to have_content domain.name
    expect(find('.history-table')).to have_content other_host.domain.name
    expect(page).to have_selector('.history-table tbody tr', count: 3)
  end

  describe 'live domain' do
    it 'should show blog in select options' do
      visit domain_hosts_path(domain)
      blog_option = find("#host_blog_id option[value='#{blog.id}']")
      expect(blog_option.text).to eq blog.title
    end

    it 'create' do
      visit domain_hosts_path(domain)
      select blog.title, from: 'host[blog_id]'
      fill_in 'host[wp_login]', with: 'test'
      fill_in 'host[wp_password]', with: 'password'
      fill_in 'host[blog_title]', with: 'blog title'
      fill_in 'host[author]', with: 'John Doe'
      fill_in 'host[description]', with: 'Blog Description'

      click_button I18n.t('button.create')
      expect(page).to have_flash I18n.t('notifications.host_created')
      expect(page).to have_content 'test'
      expect(page).to have_content hide_password('password')
      expect(page).to have_content 'blog title'
      expect(page).to have_content 'John Doe'
      expect(page).to have_content 'Blog Description'
    end

    it 'create and update after' do
      visit domain_hosts_path(domain)
      select blog.title, from: 'host[blog_id]'
      fill_in 'host[wp_login]', with: 'test'
      fill_in 'host[wp_password]', with: 'password'
      fill_in 'host[blog_title]', with: 'blog title'
      fill_in 'host[author]', with: 'John Doe'
      fill_in 'host[description]', with: 'Blog Description'
      find(:css, "label[for='host_cpanel_role_root'] .collection_radio_buttons").click
      click_button I18n.t('button.create')
      expect(page).to have_flash I18n.t('notifications.host_created')
      expect(page).to have_content 'Root'
      visit edit_domain_host_path(domain, domain.host)
      fill_in 'host[wp_login]', with: 'test123'
      fill_in 'host[wp_password]', with: '123456'
      fill_in 'host[blog_title]', with: 'blog title 1'
      fill_in 'host[author]', with: 'Jane Doe'
      fill_in 'host[description]', with: 'New Description'
      find(:css, "label[for='host_cpanel_role_addon'] .collection_radio_buttons").click
      click_button I18n.t('button.update')
      expect(page).to have_flash I18n.t('notifications.host_updated')
      expect(page).to have_content 'test123'
      expect(page).to have_content 'Addon'
      expect(page).to have_content hide_password('123456')
      expect(page).to have_content 'blog title 1'
      expect(page).to have_content 'Jane Doe'
      expect(page).to have_content 'New Description'
    end

    it 'history show all blog hosts' do
      check_blog_history
    end

    it 'show all blog hosts if domain did not have active host' do
      check_domain_history
    end
  end

  describe 'inactive domain' do
    before do
      domain.inactive!
    end

    it 'can\'t create host' do
      visit domain_hosts_path(domain)

      expect(page).to_not have_selector('#new_host')
      expect(page).to_not have_content I18n.t('button.create')
      expect(page).to have_content I18n.t('hosts.index.history_title')
    end

    it 'can show host info, but can\'t edit' do
      host = create :host, domain: domain, active: true
      visit domain_hosts_path(domain)

      expect(domain.host).to eq host

      expect(page).to have_content I18n.t("hosts.sync_mode.#{host.sync_mode}")
      expect(page).to have_content host.blog.title
      expect(page).to have_content host.blog_type.humanize

      expect(page).to have_content I18n.t('hosts.index.history_title')

      visit edit_domain_host_path(domain, domain.host)

      expect(current_path).to eq root_path
      expect(page).to have_flash I18n.t('notifications.access_denied')
    end

    it 'history show all blog hosts' do
      check_blog_history
    end

    it 'show all blog hosts if domain did not have active host' do
      check_domain_history
    end
  end
end
