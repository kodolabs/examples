require 'rails_helper'

describe Facebook::FetchPageLikes do
  let(:user)      { create :user }
  let(:customer)  { user.customer }
  let(:account) { create(:account, :with_facebook_page, customer: customer, token: '123') }
  let(:page) { account.pages.facebook.last }
  let(:owned_page) { page.owned_pages.last }

  before { Timecop.freeze Time.zone.local(2016, 10, 24, 15, 0, 0) }
  after { Timecop.return }

  context 'success', :stub_facebook do
    it 'fetch page likes stats' do
      api = Koala::Facebook::API.new(owned_page.token)
      service = Facebook::FetchPageLikes.new(api, page, since: 2.weeks.ago.to_i)
      expect(service.call).to be_truthy
    end
  end
end
