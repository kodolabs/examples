require 'rails_helper'

describe Campaigns::Delete do
  let!(:command) { Campaigns::Delete }
  let!(:campaign) { create(:campaign, :with_fb_ids) }

  it 'should destroy campaign' do
    expect_any_instance_of(Facebook::AdsService).to(
      receive(:delete).and_return(:true)
    )
    expect { command.call(campaign) }.to change(Campaign, :count).by(-1)
  end
end
