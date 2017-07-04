require 'rails_helper'

describe Campaigns::AssociateWithLinks do
  let!(:domain) { create :domain, name: 'google.com', status: :active, index_status: :indexed }
  let!(:client) { create :client }
  let!(:campaign1) { create :campaign, client: client, domain: 'www.haironthemove2u.com.au' }
  let!(:campaign2) { create :campaign, client: client, domain: 'www.campaign.com.au' }
  let!(:blog) { create :blog }
  let!(:host) { create :host, domain: domain, blog: blog, active: true }
  let!(:article) { create :article, blog: blog }
  let!(:link1) { create :link, article: article, link_url: 'http://www.haironthemove2u.com.au/info' }
  let!(:link2) { create :link, article: article, link_url: 'http://www.haironthemove2u.com.au/home' }
  let!(:link3) do
    create :link, article: article, campaign: campaign1, link_url: 'http://www.haironthemove2u.com.au/stuff'
  end

  describe '.call' do
    context 'success' do
      it 'should associate links without campaign and calculate health' do
        expect(campaign1.links.count).to eq 1
        Campaigns::AssociateWithLinks.call(campaign_id: campaign1.id)
        expect(campaign1.links.count).to eq 3
        expect(campaign1.reload.health.to_f).to eq 100.0
      end

      it 'should not associate if links not found' do
        expect(campaign2.links.count).to eq 0
        Campaigns::AssociateWithLinks.call(campaign_id: campaign2.id)
        expect(campaign2.links.count).to eq 0
        expect(campaign1.reload.health).to eq nil
      end
    end
  end
end
