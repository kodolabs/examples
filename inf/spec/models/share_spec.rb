require 'rails_helper'

describe Share do
  context 'demo' do
    let(:customer) { create(:customer, :demo) }
    let(:share) { create(:share, customer: customer) }
    let(:share2) { create(:share) }

    specify 'success' do
      share
      share2
      expect(Share.demo).to eq [share]
    end
  end

  context 'only_linkedin?' do
    specify 'success' do
      share = create(:share, :linkedin)
      expect(share.only_linkedin?).to be_truthy
    end

    specify 'false' do
      share = create(:share, :linkedin, :facebook)
      share2 = create(:share)
      expect(share.only_linkedin?).to be_falsey
      expect(share2.only_linkedin?).to be_falsey
    end
  end
end
