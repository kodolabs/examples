require 'rails_helper'

describe Campaigns::ClientIds do
  describe '.call' do
    context 'should return empty array' do
      it 'if ids blank' do
        expect(Campaigns::ClientIds.new(nil).query).to eq([])
      end
    end

    context 'should return array' do
      it 'with active client ids' do
        client = create :client
        client2 = create :client, :inactive
        campaign = create :campaign, client: client
        campaign2 = create :campaign, client: client2
        ids = [campaign.id, campaign2.id]
        expect(Campaigns::ClientIds.new(ids).query).to eq([client.id])
      end

      it 'of uniq active client ids' do
        client = create :client
        client2 = create :client
        campaign = create :campaign, client: client
        campaign2 = create :campaign, client: client2
        campaign3 = create :campaign, client: client2
        ids = [campaign.id, campaign2.id, campaign3.id]
        expect(Campaigns::ClientIds.new(ids).query).to eq([client.id, client2.id])
      end
    end
  end
end
