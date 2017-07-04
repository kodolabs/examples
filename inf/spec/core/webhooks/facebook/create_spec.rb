require 'rails_helper'

describe Webhooks::Facebook::Create do
  context 'success' do
    let(:service) { Webhooks::Facebook::Create }
    let(:account) { create(:account, :with_facebook_page) }
    let(:page) { account.pages.last }
    let(:owned_page) { account.owned_pages.last }

    specify 'process' do
      account

      allow_any_instance_of(Koala::Facebook::API).to receive(:put_connections)
      expect_any_instance_of(Koala::Facebook::API).to receive(:put_connections)
        .with(page.uid, 'subscribed_apps')
      service.new(owned_page.id).call
    end
  end
end
