require 'rails_helper'

RSpec.describe Network, type: :model do
  describe 'check related record after destroy' do
    it 'domain' do
      network = create :network
      domain = create :domain, network: network
      expect(domain.network_id).to eq network.id

      network.destroy
      expect(domain.reload.network_id).to be_nil
    end

    it 'campaigns' do
      network = create :network
      campaign = create :campaign
      create :campaigns_network, network: network, campaign: campaign

      expect(campaign.campaigns_networks.count).to eq 1
      expect(campaign.campaigns_networks.first.network_id).to eq network.id

      network.destroy
      expect(campaign.reload.campaigns_networks.count).to eq 0
    end
  end
end
