require 'rails_helper'

describe Facebook::FetchDemographics do
  let(:user) { create :user }
  let(:customer) { user.customer }
  let(:service) { Facebook::FetchDemographics }

  context 'success' do
    let(:account) { create(:account, :demographics) }
    let(:page) { account.pages.facebook.last }
    let(:owned_page) { page.owned_pages.last }
    it 'valid page' do
      api = Koala::Facebook::API.new(owned_page.token)
      allow(api).to receive(:get_connection).once
      expect(api).to receive(:get_connection).once
      service.new(api, page, since: 2.days.ago.to_i).call
    end
  end
end
