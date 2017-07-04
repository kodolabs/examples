require 'rails_helper'

describe Campaigns::Create do
  context 'success' do
    let(:user) { create(:user) }
    let(:client) { create(:client, manager: user) }
    let(:valid_params) do
      {
        domain: 'www.example.com',
        network_ids: ['', '2', '3'],
        seo: '1',
        seo_amount: '100',
        ppc: '0',
        ppc_amount: '',
        social: '1',
        social_amount: '150',
        contract_period: '24',
        brand: 'resolve',
        started_at: '10/09/2017'
      }
    end
    let(:campaign_form) { Campaigns::CampaignForm.from_params(valid_params) }

    specify 'create campaigns with newtworks and services' do
      Campaigns::Create.call(campaign_form, client)
      expect(Campaign.count).to eq(1)
      expect(CampaignsNetwork.count).to eq(2)
      expect(CampaignsService.count).to eq(2)

      campaign = Campaign.last
      expect(campaign.amount).to eq(250)
    end
  end
end
