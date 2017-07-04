require 'rails_helper'

describe Alerts::Create do
  let!(:domain) { create :domain }

  describe 'reindexed alert' do
    context 'with indexed domain' do
      it 'should be created' do
        Alerts::Create.new(domain, :domain_reindexed).call
        expect(Alert.count).to eq 1
        expect(Notification.count).to eq 1
        expect(Alert.first.kind).to eq 'domain_reindexed'
        expect(Alert.first.description).to include(domain.name)
        expect(Alert.first.description).to include('re-indexed')
      end
    end
  end

  describe 'deindexed alert' do
    context 'with not indexed domain' do
      it 'should be created' do
        Alerts::Create.new(domain, :domain_deindexed).call
        expect(Alert.count).to eq 1
        expect(Notification.count).to eq 1
        expect(Alert.first.kind).to eq 'domain_deindexed'
        expect(Alert.first.description).to include(domain.name)
        expect(Alert.first.description).to include('de-indexed')
      end
    end
  end
end
