require 'rails_helper'

describe Proxy::Search do
  let!(:domain) { create :domain, name: 'google.com' }
  let!(:proxy) { create :proxy }

  describe '.call' do
    context 'track proxy stats' do
      it 'success' do
        expect(proxy.errors_count).to eq 0
        expect(proxy.success_count).to eq 0

        allow_any_instance_of(Proxy::Search).to receive(:open_url).and_return('')

        Proxy::Search.new(domain).call

        expect(proxy.reload.errors_count).to eq 0
        expect(proxy.reload.success_count).to eq 1
      end

      it 'errors' do
        expect(proxy.errors_count).to eq 0
        expect(proxy.success_count).to eq 0

        allow_any_instance_of(Proxy::Search).to receive(:open_url).and_raise('')

        Proxy::Search.new(domain).call

        expect(proxy.reload.errors_count).to eq 1
        expect(proxy.reload.success_count).to eq 0
      end
    end
  end
end
