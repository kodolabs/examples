require 'rails_helper'

describe Domains::TrackIndexStatusChange do
  let!(:domain) { create :domain, name: 'google.com' }
  let!(:host) { create :host, domain: domain, active: true }
  let!(:article) { create :article, blog: host.blog }
  let!(:campaign) { create :campaign }
  let!(:link1) { create :link, article: article, campaign: campaign }
  let!(:link2) { create :link, article: article, campaign: campaign }

  before { Rails.cache.write("#{campaign.cache_key}-links", 20) }

  describe '.call' do
    context 'domain index status index_unknown' do
      it 'change to indexed' do
        domain.indexed!
        expect(campaign.health.to_f).to eq 0.0
        Domains::TrackIndexStatusChange.call(
          domain: domain, blog: domain.blog, old_status: :index_unknown, new_status: :indexed
        )
        expect(Alert.count).to eq 0
        expect(campaign.reload.health.to_f).to eq 100.0
        expect(Task.deindexed.count).to eq 0
      end

      it 'change to not_indexed' do
        domain.not_indexed!
        expect(campaign.health.to_f).to eq 0.0
        Domains::TrackIndexStatusChange.call(
          domain: domain, blog: domain.blog, old_status: :index_unknown, new_status: :not_indexed
        )
        expect(Alert.count).to eq 1
        expect(campaign.reload.health.to_f).to eq 0.0
        expect(Task.deindexed.count).to eq 1
      end
    end

    context 'domain index status indexed' do
      it 'change to not_indexed' do
        domain.not_indexed!
        Domains::TrackIndexStatusChange.call(
          domain: domain, blog: domain.blog, old_status: :indexed, new_status: :not_indexed
        )
        expect(Alert.count).to eq 1
        expect(campaign.reload.health.to_f).to eq 0.0
        expect(Task.deindexed.count).to eq 1
      end
    end

    context 'domain index status not_indexed' do
      it 'change to indexed' do
        domain.indexed!
        expect(campaign.health.to_f).to eq 0.0
        Domains::TrackIndexStatusChange.call(
          domain: domain, blog: domain.blog, old_status: :not_indexed, new_status: :indexed
        )
        expect(Alert.count).to eq 1
        expect(campaign.reload.health.to_f).to eq 100.0
        expect(Task.deindexed.count).to eq 0
      end
    end
  end
end
