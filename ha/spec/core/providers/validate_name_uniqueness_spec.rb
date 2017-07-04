require 'rails_helper'

describe Providers::ValidateNameUniqueness do
  describe '.call' do
    context 'should return false' do
      it 'if provider name is not unique' do
        provider = create :provider, name: 'ProHost'
        create :provider, name: 'ProHost'
        expect(Providers::ValidateNameUniqueness.new(provider, 'ProHost').valid?).to be_falsey
      end
    end

    context 'should return true' do
      it 'if provider name is unique' do
        provider = create :provider, name: 'ProHost'
        create :provider, name: 'HostPro'
        expect(Providers::ValidateNameUniqueness.new(provider, 'ProHost').valid?).to be_truthy
      end
    end
  end
end
