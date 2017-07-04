require 'rails_helper'

describe Search::Commands::SourcePages::Facebook do
  context 'success' do
    specify 'fetch results', :stub_facebook_auth do
      p = { q: 'Esquire', provider: 'facebook' }
      valid_result = [{ title: 'Esquire', handle: 'esquire' }]
      api_result = [{ 'username' => 'esquire', 'name' => 'Esquire' }]
      allow_any_instance_of(Koala::Facebook::API).to receive('search').and_return(api_result)
      res = Search::Commands::SourcePages::Facebook.new(p, build(:customer)).call
      expect(res).to eq(valid_result)
    end
  end
end
