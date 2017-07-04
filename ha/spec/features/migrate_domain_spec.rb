require 'rails_helper'

feature 'Migrate domain to new' do
  let!(:network1) { create :network, title: 'Epic 1' }
  let!(:network2) { create :network, title: 'Epic 2' }
  let!(:network3) { create :network, title: 'Epic 3' }

  let!(:domain_for_migrate) { create :domain, network: network1, status: :active }
  let!(:domain1) { create :domain, network: network1, status: :pending }
  let!(:domain2) { create :domain, network: network1, status: :active }
  let!(:domain3) { create :domain, network: network2, status: :pending }
  let!(:domain4) { create :domain, network: network3, status: :pending }
  let!(:domain5) { create :domain, network: nil, status: :pending }

  before do
    user_sign_in
  end

  describe 'domain did not have active host' do
    it 'should be redirect to domain show page' do
      visit domain_migrations_path(domain_for_migrate)
      expect(current_path).to eq domain_path(domain_for_migrate)
      expect(page.find('.list-group.mail-list')).not_to have_content(I18n.t('domains.submenu.articles'))
      expect(page.find('.list-group.mail-list')).not_to have_content(I18n.t('domains.submenu.links'))
      expect(page.find('.list-group.mail-list')).not_to have_content(I18n.t('domains.submenu.migrations'))
    end
  end

  describe 'domain has host and blog' do
    let!(:blog) { create :blog }
    let!(:host) { create :host, domain: domain_for_migrate, blog: blog, active: true }

    it 'can open migration page and have menu' do
      visit domain_migrations_path(domain_for_migrate)
      expect(current_path).to eq domain_migrations_path(domain_for_migrate)

      expect(page.find('.list-group.mail-list')).to have_content(I18n.t('domains.submenu.articles'))
      expect(page.find('.list-group.mail-list')).to have_content(I18n.t('domains.submenu.links'))
      expect(page.find('.list-group.mail-list')).to have_content(I18n.t('domains.submenu.migrations'))
    end

    it 'new domains should be from same network and have pending status' do
      visit domain_migrations_path(domain_for_migrate)

      expect(page).to have_selector('#form_domain_id option', count: 2)
      domains_ids = page.all('#form_domain_id option').map(&:value).reject(&:blank?)
      expect(domains_ids.size).to eq 1
      expect(domains_ids.first.to_i).to eq domain1.id
      expect(domain1.status).to eq 'pending'
    end

    it 'success migrate to new domain - deactivate old host' do
      visit domain_migrations_path(domain_for_migrate)
      expect(domain_for_migrate.host.present?).to be_truthy
      expect(domain1.status).to eq 'pending'

      choose I18n.t('domains.form.migrate_to_new_domain')
      select = page.find('select#form_domain_id')
      select.select domain1.name

      click_button 'Create'

      expect(page).to have_flash I18n.t('notifications.migration_created')
      expect(current_path).to eq domain_hosts_path(domain1)
      expect(domain1.reload.status).to eq 'active'
      expect(domain_for_migrate.reload.host.present?).to be_falsey
    end

    it 'success migrate to same domain' do
      visit domain_migrations_path(domain_for_migrate)
      choose I18n.t('domains.form.migrate_to_same_domain')

      click_button 'Create'

      expect(page).to have_flash I18n.t('notifications.migration_created')
      expect(current_path).to eq domain_hosts_path(domain_for_migrate)
      expect(domain_for_migrate.reload.status).to eq 'active'
    end

    it "don't show current domain on select list" do
      domain_for_migrate.pending!

      visit domain_migrations_path(domain_for_migrate)

      expect(page).to have_selector('#form_domain_id option', count: 2)
      domains_ids = page.all('#form_domain_id option').map(&:value).reject(&:blank?)
      expect(domains_ids.size).to eq 1
      expect(domains_ids.first.to_i).to eq domain1.id
    end

    it 'success migrate to new domain - clone old host' do
      visit domain_migrations_path(domain_for_migrate)
      host = domain_for_migrate.host
      expect(host.present?).to be_truthy
      expect(domain1.status).to eq 'pending'

      choose I18n.t('domains.form.migrate_to_new_domain')
      select = page.find('select#form_domain_id')
      select.select domain1.name
      choose I18n.t('migrations.host_actions.empty_blog')

      click_button 'Create'

      expect(page).to have_flash I18n.t('notifications.migration_created')
      expect(current_path).to eq domain_hosts_path(domain1)
      expect(domain1.reload.status).to eq 'active'

      domain_for_migrate.reload
      expect(domain_for_migrate.host.present?).to be_truthy
      expect(host).to_not eq domain_for_migrate.host
    end
  end
end
