require 'rails_helper'

describe UpdatePublication do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:account) { create(:account, :facebook, :with_facebook_page, customer: customer) }
  let(:article) { create(:article, customer: customer) }
  let(:share) { create(:share, shareable: article) }
  let(:owned_page) { account.owned_pages.first }
  let(:page) { account.pages.last }
  let(:publication) { create(:publication, share: share, owned_page_id: owned_page.id) }
  let(:post) { create(:post, page: page, uid: 'some_uid') }

  context 'success' do
    specify 'update publication' do
      publication
      post
      allow_any_instance_of(RecentPostsWorker).to receive(:perform)
      service = UpdatePublication.new(publication, article, 'some_uid')
      service.call
      updated_publication = publication.reload
      expect(updated_publication.uid).to eq('some_uid')
      expect(updated_publication.published_post_id).to eq(post.id)
    end
  end
end
