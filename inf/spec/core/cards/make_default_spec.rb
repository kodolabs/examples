require 'rails_helper'

describe Cards::MakeDefault do
  let!(:customer) { create(:customer) }
  let!(:default_card) { create(:card, customer: customer, default: true) }
  let!(:card) { create(:card, customer: customer) }
  let!(:service) { Cards::MakeDefault }

  it 'should make card as default' do
    Cards::MakeDefault.call(card)
    expect(card.reload.default).to eq(true)
    expect(default_card.reload.default).to eq(false)
  end
end
