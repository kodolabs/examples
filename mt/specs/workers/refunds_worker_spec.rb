require 'rails_helper'

describe RefundsWorker do
  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:token)         { stripe_helper.generate_card_token(last4: '9191', exp_year: 2055) }
  let(:user)          { create :user }
  let(:patient)       { create :patient, user: user }
  let!(:hospital)     { create :hospital, plus_partner: true }
  let!(:procedure)    { create :procedure, hospitals: [hospital], parent: create(:procedure)  }
  let!(:demand)       { create :demand, patient: patient, procedures: [procedure], hospitals: [hospital] }
  let!(:enquiry)      { demand.enquiries.first }
  let!(:proposal)     { create(:proposal, with_procedures: [procedure], enquiry: enquiry) }

  before do
    StripeMock.start
    stripe_service = StripeService.new(patient, token)
    _success, card = stripe_service.authorize
    enquiry.update_attribute(:workflow_state, 'payment_requested')

    2.times { create :payment_request, enquiry: enquiry, price: 50 }
    enquiry.payment_requests.each { |r| stripe_service.pay(r, card) }

    stripe_service.pay(enquiry, card)
    enquiry.update_attribute(:workflow_state, 'payment_cancelled')
  end
  after { StripeMock.stop }

  it 'should run correctly for the first time' do
    expect(Stripe::Charge).to receive(:create).once.and_call_original

    described_class.new.perform(enquiry.id)

    expect(Payment.refunded.count).to eq(3)
    expect(enquiry.cancellation_fee.present?).to eq(true)
  end

  it 'should retry correctly if one of refunds fails' do
    allow_any_instance_of(StripeService).to receive(:refund).and_return(false)

    expect { described_class.new.perform(enquiry.id) }.to raise_error(RefundsWorker::StripeIntegrationError)

    allow_any_instance_of(StripeService).to receive(:refund).and_call_original

    described_class.new.perform(enquiry.id)

    expect(Payment.refunded.count).to eq(3)
    expect(enquiry.cancellation_fee.present?).to eq(true)
  end
end
