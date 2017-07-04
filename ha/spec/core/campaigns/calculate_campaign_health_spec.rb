require 'rails_helper'

describe Campaigns::CalculateCampaignHealth do
  let!(:domain) { create :domain, name: 'google.com', status: :active, index_status: :indexed }
  let!(:client) { create :client }
  let!(:campaign1) { create :campaign, client: client, domain: 'www.haironthemove2u.com.au' }
  let!(:campaign2) { create :campaign, client: client, domain: 'www.campaign.com.au' }
  let!(:blog) { create :blog }
  let!(:host) { create :host, domain: domain, blog: blog, active: true }
  let!(:article) { create :article, blog: blog }
  let!(:link1) do
    create :link, article: article, campaign: campaign1, link_url: 'http://www.haironthemove2u.com.au/info'
  end
  let!(:link2) do
    create :link, article: article, campaign: campaign1, link_url: 'http://www.haironthemove2u.com.au/home'
  end

  describe '.call' do
    context 'success' do
      it 'should calculate health' do
        expect(campaign1.links.count).to eq 2
        Campaigns::CalculateCampaignHealth.call(campaign: campaign1)
        expect(campaign1.reload.health.to_f).to eq 100.0
      end

      it 'should return nil if no links' do
        expect(campaign2.links.count).to eq 0
        Campaigns::CalculateCampaignHealth.call(campaign: campaign2)
        expect(campaign1.reload.health).to eq nil
      end
    end
  end
end
