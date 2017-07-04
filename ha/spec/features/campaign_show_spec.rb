require 'rails_helper'

feature 'Campaigns' do
  let!(:client) { create :client }
  let!(:campaign) { create :campaign, client: client }

  before do
    user_sign_in
  end

  def init_domain_with_link(index_status)
    domain = create :domain, index_status: index_status
    host = create :host, domain: domain, active: true
    article = create :article, blog: host.blog
    create :link, article: article, campaign: campaign
    domain
  end

  describe 'show' do
    it 'should show campaign info' do
      visit client_campaign_path(id: campaign.id, client_id: client.id)

      expect(page).to have_content campaign.domain
      expect(page).to have_content client.name
      expect(page).to have_content campaign.brand.humanize
      expect(page).to have_content campaign.started_at.to_s(:short)

      campaign.networks.each do |n|
        expect(page).to have_content n.title.humanize
      end
      campaign.campaigns_services.each do |n|
        expect(page).to have_content n.service_type.upcase
      end
    end

    it 'should campaign links' do
      domain = init_domain_with_link(:indexed)

      visit client_campaign_path(id: campaign.id, client_id: client.id)

      expect(page).to have_selector('#campaign-links-table tbody tr', count: 1)
      expect(page).to have_selector('#campaign-links-table tbody tr.inactive', count: 0)

      domain.not_indexed!

      visit client_campaign_path(id: campaign.id, client_id: client.id)

      expect(page).to have_selector('#campaign-links-table tbody tr', count: 1)
      expect(page).to have_selector('#campaign-links-table tbody tr.inactive', count: 1)
    end

    it 'should campaign links sorted by domain indexation' do
      domain_unknown = init_domain_with_link(:index_unknown)
      domain_indexed = init_domain_with_link(:indexed)
      domain_not_indexed = init_domain_with_link(:not_indexed)

      visit client_campaign_path(id: campaign.id, client_id: client.id)

      expect(page).to have_selector('#campaign-links-table tbody tr', count: 3)
      expect(page).to have_selector('#campaign-links-table tbody tr.inactive', count: 1)

      links = page.all('#campaign-links-table tbody tr').to_a

      expect(links.first).to have_content(domain_not_indexed.name)
      expect(links.second).to have_content(domain_unknown.name)
      expect(links.third).to have_content(domain_indexed.name)
    end
  end
end
