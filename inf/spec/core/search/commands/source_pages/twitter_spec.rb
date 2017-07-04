require 'rails_helper'

describe Search::Commands::SourcePages::Twitter do
  context 'success' do
    let(:customer) { create(:customer) }
    let(:account) { create(:account, :twitter, :with_twitter_page, customer: customer) }

    specify 'fetch results' do
      account
      valid_results = [
        { title: 'Smirnoff', handle: 'SmirnoffEurope' },
        { title: 'Smirnoff US', handle: 'SmirnoffUS' }
      ]

      api_results = [
        OpenStruct.new(name: 'Smirnoff', screen_name: 'SmirnoffEurope'),
        OpenStruct.new(name: 'Smirnoff US', screen_name: 'SmirnoffUS')
      ]

      params = { q: 'smirnoff', provider: 'facebook' }
      client = double('Twitter::REST::Client')
      allow(client).to receive(:user_search).and_return(api_results)

      allow_any_instance_of(Twitter::Service).to receive(:client).and_return(client)
      service = Search::Commands::SourcePages::Twitter.new(params, customer)

      res = service.call
      expect(res).to eq(valid_results)
    end
  end
end
