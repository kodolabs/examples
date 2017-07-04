require 'rails_helper'

describe FollowedPages::Facebook do
  let(:service) { FollowedPages::Facebook }
  let(:fb_service) { Facebook::Service }
  let(:account) { create(:account, :facebook) }

  context 'success' do
    specify 'fetch liked pages' do
      api_picture = { data: { url: 'http://image.jpg' } }
      api_page = {
        name: 'Page title',
        picture: api_picture,
        username: 'User'
      }.with_indifferent_access
      api_pages = [api_page]
      allow_any_instance_of(fb_service).to receive(:fetch_followed_pages).and_return(api_pages)
      expect_any_instance_of(fb_service).to receive(:fetch_followed_pages).once

      valid_data = [OpenStruct.new(
        title: 'Page title',
        image: 'http://image.jpg',
        handle: 'User'
      )]
      expect(service.new(account).call).to eq(valid_data)
    end
  end
end
