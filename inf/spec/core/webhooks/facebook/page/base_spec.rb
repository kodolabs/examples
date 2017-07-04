require 'rails_helper'
describe Webhooks::Facebook::Page::Base do
  let(:service) { Webhooks::Facebook::Page::Base }
  let(:info_service) { Webhooks::Facebook::Page::Info }
  let(:feed_service) { Webhooks::Facebook::Page::Feed }

  context 'success' do
    def api_entries(field)
      [
        {
          'changes' => [{ 'field' => field, 'value' => 'somevalue' }],
          'id' => 'page_uid'
        }
      ]
    end

    specify 'page info' do
      entries = api_entries('picture')
      allow_any_instance_of(info_service).to receive(:call)
      expect_any_instance_of(info_service).to receive(:call).once
      service.new(entries).call
    end

    specify 'page feed' do
      entries = api_entries('feed')
      allow_any_instance_of(feed_service).to receive(:call)
      expect_any_instance_of(feed_service).to receive(:call).once
      service.new(entries).call
    end
  end
end
