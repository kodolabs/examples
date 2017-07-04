require 'rails_helper'

describe Search::Commands::SourcePages::Base do
  let(:params) { { q: 'Some query', provider: providers(:twitter).id } }
  let(:service) { Search::Commands::SourcePages::Base }
  context 'success' do
    specify 'fetch results' do
      expect_any_instance_of(Search::Commands::SourcePages::Twitter).to receive(:call)
      service.new(params, build(:customer)).call
    end
  end

  context 'fail' do
    specify 'some exception' do
      allow_any_instance_of(Search::Commands::SourcePages::Twitter).to receive('call').and_raise('error')
      res = service.new(params, nil).call
      expect(res).to eq []
    end
  end
end
