require 'rails_helper'

describe StripeService do
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:token)         { stripe_helper.generate_card_token(last4: '9191', exp_year: 2055) }
  let(:user)          { create :user }
  let(:patient)       { create :patient, user: user }
  let(:instance)      { described_class.new(patient, token) }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#authorize' do
    it 'should handle blank data' do
      blank_instance = described_class.new(nil, nil)
      result = blank_instance.authorize

      expect(result).to eq [false, nil]
    end

    it 'should authorize with new customer' do
      success, card = instance.authorize

      expect(success).to eq true
      expect(card.last_four).to eq '9191'
      expect(patient.stripe_id.present?).to eq true
    end

    it 'should authorize with existing stripe customer' do
      customer = Stripe::Customer.create(source: token)
      patient.update(stripe_id: customer.id)
      other_token = stripe_helper.generate_card_token(last4: '4242', exp_year: 2022)
      success, card = described_class.new(patient, other_token).authorize

      expect(success).to eq true
      expect(card.last_four).to eq '4242'
      expect(patient.stripe_id).to eq customer.id
    end

    it 'should handle error' do
      stripe_helper.prepare_card_error
      result = instance.authorize

      expect(result).to eq [false, nil]
    end
  end

  describe '#pay' do
    let(:hospital) { create :hospital }
    let(:procedure) { create :procedure, hospitals: [hospital], parent: create(:procedure) }
    let(:demand) { create :demand, patient: patient, procedures: [procedure], hospitals: [hospital] }
    let(:enquiry) { demand.enquiries.first }
    let!(:proposal) { create(:proposal, with_procedures: [procedure], enquiry: enquiry) }

    before { _success, @card = instance.authorize }

    it 'should handle blank data' do
      blank_instance = described_class.new(nil, nil)
      result = blank_instance.pay(nil, nil)

      expect(result).to eq [false, nil]
    end

    describe 'for plus subscription' do
      it 'should handle unchargable request' do
        expect(instance.pay(enquiry, @card)).to eq [false, nil]
      end

      it 'should create payment' do
        hospital.update_attribute(:plus_partner, true)
        success, payment = instance.pay(enquiry, @card)

        expect(success).to eq true
        expect(payment.price).to eq 100
      end

      it 'should handle stripe error' do
        hospital.update_attribute(:plus_partner, true)
        StripeMock.prepare_card_error(:processing_error)

        expect(instance.pay(enquiry, @card)).to eq [false, nil]
      end
    end

    describe 'for payment request' do
      before do
        create :proposal, enquiry: enquiry, with_procedures: [procedure]
        enquiry.update_attribute(:workflow_state, 'payment_requested')
      end
      let(:request) { create :payment_request, enquiry: enquiry }

      it 'should create payment' do
        success, payment = instance.pay(request, @card)

        expect(success).to eq true
        expect(payment.price).to eq 1000
      end

      it 'should handle stripe error' do
        StripeMock.prepare_card_error(:processing_error)

        expect(instance.pay(enquiry, @card)).to eq [false, nil]
      end
    end
  end

  describe '#refund' do
    let!(:hospital) { create :hospital }
    let!(:procedure) { create :procedure, hospitals: [hospital], parent: create(:procedure) }
    let!(:demand) { create :demand, patient: patient, procedures: [procedure], hospitals: [hospital] }
    let!(:enquiry) { demand.enquiries.first }
    let!(:proposal) { create(:proposal, with_procedures: [procedure], enquiry: enquiry) }

    it 'should handle blank data' do
      expect(instance.refund(nil)).to eq(true)
    end

    describe 'with payable payment request' do
      before do
        _success, card = instance.authorize
        enquiry.update_attribute(:workflow_state, 'payment_requested')
        request = create :payment_request, enquiry: enquiry, price: 39.99
        _success, @payment = instance.pay(request, card)
        enquiry.update_attribute(:workflow_state, 'payment_cancelled')
      end

      it 'should make stripe refund call' do
        result = instance.refund(@payment.reload)

        expect(result).to eq(true)
        expect(@payment.stripe_refund_id.class).to eq(String)
        expect(@payment.error_message).to eq('')
      end
    end
  end
end
