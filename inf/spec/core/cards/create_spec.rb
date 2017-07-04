require 'rails_helper'

describe Cards::Create do
  let!(:customer) { create(:customer) }
  let!(:default_card) { create(:card, customer: customer, default: true) }
  let!(:service) { Cards::Create }

  context 'failed' do
    it 'should not create card with wrong attributes' do
      params = { 'card' => {
        'name' => 'name',
        'address' => 'address'
      } }
      form = Cards::CardForm.from_params(params)
      service.call(form, customer)
      expect(customer.cards.count).to eq(1)
    end
  end

  context 'success' do
    it 'should create new card and make it as default' do
      params = { 'card' => {
        'name' => 'name',
        'address' => 'address',
        'city' => 'city',
        'postcode' => 'postcode',
        'country' => 'country',
        'brand' => 'visa',
        'last4' => '4242',
        'stripe_token' => 'tok_4242',
        'stripe_id' => 'card_4242'
      } }
      expect_any_instance_of(service).to(receive(:assign_stripe_card).and_return(true))
      form = Cards::CardForm.from_params(params)
      service.call(form, customer)
      expect(customer.cards.count).to eq(2)
      expect(default_card.reload.default).to eq(false)
      expect(customer.cards.last.default).to eq(true)
    end
  end
end
