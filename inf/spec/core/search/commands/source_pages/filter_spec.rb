require 'rails_helper'

describe Search::Commands::SourcePages::Filter do
  let(:service) { Search::Commands::SourcePages::Filter }
  let(:customer) { create(:customer, :with_active_subscr) }
  let(:provider) { providers(:twitter) }

  context 'success' do
    let(:res1) { { title: 'BBC', handle: 'bbc' } }
    let(:res2) { { handle: 'awesome', title: 'Awesome' } }
    let(:response) { [res1, res2] }

    let(:twitter_account) { create(:account, :twitter, customer: customer) }
    let(:twitter_page) { create(:page, :twitter, handle: 'bbC') }
    let(:source_page) { create :source_page, title: 'test', feed: customer.feeds.first, page: twitter_page }

    specify 'filter' do
      source_page
      res = service.new(response, customer: customer, provider: provider).call
      expect(res).to eq([res2])
    end
  end
end
