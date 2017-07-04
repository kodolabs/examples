require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe 'check' do
    it 'collections' do
      expect(Provider.collections.count).to eq 0
      expect(Provider.host_collections.count).to eq 0
      expect(Provider.dns_collections.count).to eq 0
      expect(Provider.collections_by_type(:host).count).to eq 0
      expect(Provider.collections_by_type(:dns).count).to eq 0

      create :provider, provider_type: :host

      expect(Provider.collections.count).to eq 1
      expect(Provider.host_collections.count).to eq 1
      expect(Provider.dns_collections.count).to eq 0
      expect(Provider.collections_by_type(:host).count).to eq 1
      expect(Provider.collections_by_type(:dns).count).to eq 0

      create :provider, provider_type: :dns

      expect(Provider.collections.count).to eq 2
      expect(Provider.host_collections.count).to eq 1
      expect(Provider.dns_collections.count).to eq 1
      expect(Provider.collections_by_type(:host).count).to eq 1
      expect(Provider.collections_by_type(:dns).count).to eq 1

      expect(Provider.collection_by_type.count).to eq 2
      expect(Provider.collection_by_type(:host).count).to eq 1
      expect(Provider.collection_by_type(:dns).count).to eq 1

      create :provider, provider_type: :dns

      expect(Provider.collection_by_type.count).to eq 3
      expect(Provider.collection_by_type(:host).count).to eq 1
      expect(Provider.collection_by_type(:dns).count).to eq 2
    end
  end
end
