require 'rails_helper'

describe Cards::Delete do
  let!(:customer) { create(:customer) }
  let!(:default_card) { create(:card, customer: customer, default: true) }
  let!(:card) { create(:card, customer: customer) }
  let!(:service) { Cards::Delete }

  context 'success' do
    it 'should delete default card and assign another as default' do
      expect_any_instance_of(service).to(receive(:delete_on_stripe).and_return(true))
      expect(customer.cards.count).to eq(2)
      service.call(default_card)
      expect(customer.cards.count).to eq(1)
      expect(card.reload.default).to eq(true)
    end

    it 'should delete card' do
      expect_any_instance_of(service).to(receive(:delete_on_stripe).and_return(true))
      expect(customer.cards.count).to eq(2)
      service.call(card)
      expect(customer.cards.count).to eq(1)
    end
  end

  context 'failed' do
    it 'should not delete default card' do
      card.destroy
      expect(customer.cards.count).to eq(1)
      service.call(default_card)
      expect(customer.cards.count).to eq(1)
    end
  end
end
