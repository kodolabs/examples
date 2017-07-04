require 'rails_helper'

describe FollowedPages::Twitter do
  context 'success' do
    let(:service) { FollowedPages::Twitter }
    let(:account) { create(:account, :twitter) }
    let(:twitter_service) { Twitter::Service }

    specify 'fetch pages' do
      stub_const('FollowedPages::Twitter::MAX_COUNT', 5)
      api_page = { name: 'some name', profile_image_url: 'http://image.jpg', screen_name: 'handle' }
      api_pages = OpenStruct.new(attrs: { users: [api_page] })
      allow_any_instance_of(twitter_service).to receive(:fetch_friends_list).and_return(api_pages)
      expect_any_instance_of(twitter_service).to receive(:fetch_friends_list).with(account.username, count: 5)

      valid_data = [OpenStruct.new(title: 'some name', image: 'http://image.jpg', handle: 'handle')]
      expect(service.new(account).call).to eq(valid_data)
    end
  end
end
