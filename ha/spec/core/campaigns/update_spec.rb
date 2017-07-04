require 'rails_helper'

describe Campaigns::Create do
  context 'success' do
    let(:user) { create(:user) }
    let(:client) { create(:client, manager: user) }
    let(:network) { create(:network) }
    let(:campaign) { create(:campaign, client: client) }

    specify 'success update campaign' do
      params = Campaigns::Params.new(campaign).perform
      params.merge!(
        domain: 'www.example.com',
        network_ids: [network.id],
        seo: '1',
        seo_amount: '500',
        ppc: '0',
        ppc_amount: '',
        social: '1',
        social_amount: '150',
        contract_period: '24',
        brand: 'resolve'
      )
      campaign_form = Campaigns::CampaignForm.from_params(params)
      Campaigns::Update.call(campaign_form, campaign)

      campaign.reload

      expect(campaign.domain).to eq(params[:domain])
      expect(campaign.amount).to eq(650)
      expect(campaign.brand).to eq('resolve')

      expect(campaign.campaigns_services.count).to eq(2)
      expect(campaign.campaigns_networks.count).to eq(1)

      services = campaign.campaigns_services.map(&:service_type)
      expect(services.include?('seo')).to be_truthy
      expect(services.include?('social')).to be_truthy
      expect(services.include?('ppc')).to be_falsey
    end
  end
end
