require 'rails_helper'

RSpec.describe Proxy, type: :model do
  describe 'track stats' do
    it 'errors' do
      proxy = create :proxy

      expect(proxy.errors_count).to eq 0

      proxy.track_error!
      expect(proxy.errors_count).to eq 1
    end

    it 'successes' do
      proxy = create :proxy

      expect(proxy.success_count).to eq 0

      proxy.track_success!
      expect(proxy.success_count).to eq 1
    end
  end
end
