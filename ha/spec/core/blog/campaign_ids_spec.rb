require 'rails_helper'

describe Blogs::CampaignIds do
  describe '.call' do
    let!(:blog) { create :blog }
    context 'should return empty array' do
      it 'if blog without links' do
        expect(Blogs::CampaignIds.new(blog).query).to eq([])
      end
    end

    context 'should return array' do
      it 'with active campaign ids' do
        article = create :article, blog: blog
        campaign = create :campaign, active: false
        campaign2 = create :campaign
        create :link, article: article, campaign: campaign
        create :link, article: article, campaign: campaign2
        create :link, article: article, campaign: campaign2
        expect(Blogs::CampaignIds.new(blog).query).to eq([campaign2.id])
      end

      it 'with all campaign ids' do
        article = create :article, blog: blog
        campaign = create :campaign, active: false
        campaign2 = create :campaign
        create :link, article: article, campaign: campaign
        create :link, article: article, campaign: campaign2
        create :link, article: article, campaign: campaign2
        expect(Blogs::CampaignIds.new(blog, false).query).to eq([campaign.id, campaign2.id])
      end

      it 'of uniq campaign ids' do
        article = create :article, blog: blog
        campaign = create :campaign
        campaign2 = create :campaign
        create :link, article: article, campaign: campaign
        create :link, article: article, campaign: campaign2
        create :link, article: article, campaign: campaign2
        expect(Blogs::CampaignIds.new(blog).query).to eq([campaign.id, campaign2.id])
      end
    end
  end
end
