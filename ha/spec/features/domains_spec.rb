require 'rails_helper'

feature 'Domains' do
  let(:network1) { create :network }
  let(:network2) { create :network }

  let!(:blog1) { create :blog }
  let!(:blog2) { create :blog }
  let!(:blog3) { create :blog }

  let!(:host1) { create :host, active: true, blog: blog1, blog_type: :wordpress }
  let!(:host2) { create :host, active: true, blog: blog2 }
  let!(:host3) { create :host, active: true, blog: blog3 }

  let!(:article1) { create :article, blog: blog1 }
  let!(:article2) { create :article, blog: blog3 }
  let!(:article3) { create :article, blog: blog1 }

  let!(:campaign) { create :campaign }

  let!(:link1) { create :link, article: article1, campaign: campaign }
  let!(:link2) { create :link, article: article1, campaign: campaign }

  let!(:domain1) do
    create(:domain, network: network1, name: 'amazon.com', status: :active,
                    expires_at: Time.zone.now + 1.day, hosts: [host1], name_servers: %w(new old last))
  end
  let!(:domain2) do
    create(:domain, network: network2, name: 'google.com', status: :inactive,
                    expires_at: Time.zone.now + 2.days, index_pages: 20, hosts: [host2])
  end
  let!(:domain3) do
    create(:domain, network: network2, name: 'ebay.com', status: :inactive,
                    expires_at: Time.zone.now + 3.days, index_pages: 200, hosts: [host3])
  end

  before do
    user_sign_in
    visit domains_path
    @domains = page.all('table.domains tbody tr')
  end

  describe 'list' do
    it 'should show in order by expires date' do
      expect(@domains[0]).to have_content domain1.name
      expect(@domains[1]).to have_content domain2.name
    end

    it 'should sort by name desc' do
      page.find('th.name a.remote-sort').click
      page.find('th.name a.remote-sort').click
      expect(@domains[1]).to have_content domain2.name
      expect(@domains[0]).to have_content domain1.name
    end

    it 'should show status icon' do
      @domains[0].find('.glyphicon-ok-sign')
      @domains[1].find('.glyphicon-ban-circle')
    end

    it 'should show blog type icon and can sort' do
      @domains[0].find('.fa-wordpress')
      page.find('th.blog_type a.remote-sort').click
      expect(@domains[2]).to have_content domain3.name
      expect(@domains[1]).to have_content domain2.name
      expect(@domains[0]).to have_content domain1.name
    end

    it 'should network label' do
      expect(@domains[0]).to have_content domain1.network.title
      expect(@domains[1]).to have_content domain2.network.title
    end

    it 'should be count articles' do
      expect(@domains[0].find('td.articles')).to have_content '2'
      expect(@domains[1].find('td.articles')).to have_content ''
      expect(@domains[2].find('td.articles')).to have_content '1'
    end

    it 'should show name servers' do
      expect(@domains[0].find('i.fa-server')[:title]).to have_content 'newoldlast'
    end

    it 'should not show name servers icon if no servers' do
      expect(@domains[1]).to have_no_css('.fa-server')
      expect(@domains[2]).to have_no_css('.fa-server')
    end
  end

  describe 'Adding page' do
    before { visit new_domain_path }

    it 'should save multiple domains' do
      find('#domain_domains').set("new.com\nold.org")
      click_button 'Create'
      expect(page).to have_flash I18n.t('notifications.domains_created')
    end

    it 'should show error when domains invalid' do
      find('#domain_domains').set("new\nold")
      click_button 'Create'
      expect(page).to have_content I18n.t('notifications.invalid_domains', invalid_domains: 'new, old')
    end

    it 'should error when domain already exist' do
      create :domain, name: 'new.com'
      find('#domain_domains').set('new.com')
      click_button 'Create'
      expect(page).to have_content I18n.t('notifications.duplicate_domains', duplicate_domains: 'new.com')
    end
  end

  describe 'Show page' do
    it 'should show domain page' do
      domain1.update(index_pages: 1234, index_status: :indexed)
      visit domain_path(domain1)
      expect(page).to have_content domain1.name
      expect(page).to have_content domain1.expires_at.to_s(:short)
      expect(page).to have_content domain1.network.title
      expect(page).to have_content I18n.t('domains.show.index_pages')
      expect(page).to have_content '1,234'
      expect(page).to have_content '0%'
      expect(page).to have_content I18n.t('domains.show.uptime_percent_label',
        count: DomainStats::PERIOD_CALC_UPTIME)
      expect(page).to have_content(
        "#{I18n.t('domains.show.outbound_links')} / #{I18n.t('domains.show.active_campaigns')}"
      )
      expect(page).to have_content '2 / 1'
    end

    it 'unkonown metrics' do
      domain1.update(expires_at: nil, index_status: :index_unknown)
      visit domain_path(domain1)

      expect(page).to have_content domain1.name
      expect(page).to have_content domain1.network.title
      expect(page).to have_content [
        I18n.t('domains.empty_expire_on'),
        I18n.t('domains.show.expiration_label')
      ].join(' ')
      expect(page).to have_content [
        I18n.t('global.unknown'),
        I18n.t('domains.show.index_pages')
      ].join(' ')
      expect(page).to have_content '0%'
    end
  end

  describe 'Delete page' do
    before do
      visit delete_domain_path domain1
    end

    it 'can delete an event' do
      page.find('a.delete-btn').click
      expect(page).to have_flash I18n.t('notifications.domain_deleted')
    end

    it 'can delete an event' do
      page.find('a.delete-btn').click
      expect(page).to have_flash I18n.t('notifications.domain_deleted')
    end
  end
end
