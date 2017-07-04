require 'rails_helper'

describe CampaignDecorator do
  context 'success' do
    before { Timecop.freeze Time.zone.local(2016, 12, 15, 15, 40, 0) }
    after { Timecop.return }
    specify 'full date' do
      campaign = build(:campaign, starts_at: Time.current, duration: 14)
      record = campaign.decorate
      expect(record.start_date).to eq '15/12/16'
      expect(record.end_date).to eq '29/12/16'
    end
  end
end
