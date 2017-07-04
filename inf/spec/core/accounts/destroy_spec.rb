require 'rails_helper'

describe Accounts::Destroy do
  context 'success' do
    let(:service) { Accounts::Destroy }
    let(:account) { create(:account, :with_facebook_page, :with_analytics_config) }
    let(:owned_page) { account.owned_pages.last }
    specify 'disconnect account' do
      owned_page
      service.new(account).call
      reloaded = account.reload
      expect(reloaded.customer_id).to be_blank
      expect(owned_page.reload.account_id).to be_blank
      expect(reloaded.analytics_configs).to be_blank
    end
  end
end
