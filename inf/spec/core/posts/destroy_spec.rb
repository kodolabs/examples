require 'rails_helper'

describe Posts::Destroy do
  let(:service) { Posts::Destroy }

  context 'not published posts' do
    let(:post) { create(:post) }

    specify 'success' do
      post
      expect { service.new(post.id).call }.to change { Post.count }.from(1).to(0)
    end
  end

  context 'published' do
    let(:account1) { create(:account, :with_facebook_page) }
    let(:account2) { create(:account, :with_twitter_page) }
    let(:page1) { account1.owned_pages.last }
    let(:page2) { account2.owned_pages.last }
    let(:post) { create(:post) }
    let(:post1) { create(:post) }
    let(:post2) { create(:post) }

    let(:share1) { create(:share, :post, shareable_id: post.id) }

    let(:publication1) { create(:publication, share: share1, owned_page: page1, published_post_id: post1.id) }
    let(:publication2) { create(:publication, share: share1, owned_page: page2, published_post_id: post2.id) }

    let(:campaign1) { create(:campaign, publication: publication1) }
    let(:campaign2) { create(:campaign, publication: publication2) }

    specify 'not last target' do
      publication1
      publication2
      campaign1
      campaign2
      service.new(post2.id).call
      expect(Share.count).to eq(1)
      expect(Publication.count).to eq(1)
      expect(Publication.first).to eq(publication1)
      expect(Campaign.count).to eq(1)
      expect(Campaign.first).to eq(campaign1)
    end

    specify 'last target' do
      publication1
      allow_any_instance_of(Shares::Commands::DestroyFacebook).to receive(:call)
      service.new(post1.id).call
      expect(Share.count).to eq(0)
      expect(Publication.count).to eq(0)
    end
  end
end
