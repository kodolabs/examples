require 'rails_helper'

describe ContentDecorator do
  context 'Share' do
    let(:user) { create(:user) }
    let(:customer) { user.customer }
    let(:account) { create(:account, :with_facebook_page, customer: customer) }
    let(:post) { create(:post) }
    let(:owned_page) { account.owned_pages.first }
    let(:publication) { create(:publication, share: share, owned_page: owned_page) }
    let(:share) { create(:share, customer: customer, shareable: post) }
    let(:news) { create(:news) }
    let(:share2) { create(:share, customer: customer, shareable: news) }
    let(:publication2) { create(:publication, share: share2, owned_page: owned_page) }

    before do
      helpers = double('helpers')
      allow(helpers).to receive(:current_customer) { customer }
      allow(helpers).to receive(:edit_user_share_path) { '/shares/edit' }
      allow(helpers).to receive(:new_user_share_path) { '/shares/new?only_content=1' }
      allow(helpers).to receive(:action_name) { 'msm' }

      allow_any_instance_of(ContentDecorator).to receive(:h) { helpers }
    end

    context 'modal url' do
      specify 'new' do
        post
        news
        expect(post.decorate.share_url).to include '/shares/new?only_content=1'
        expect(news.decorate.share_url).to include '/shares/new'
      end

      specify 'edit' do
        post
        share
        publication
        news
        share2
        publication2

        expect(post.decorate.share_url).to include '/shares/edit'
        expect(news.decorate.share_url).to include '/shares/edit'
      end
    end
  end
end
