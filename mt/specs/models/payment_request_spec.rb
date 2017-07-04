require 'rails_helper'

describe PaymentRequest do
  let(:procedure) { create(:procedure) }
  let(:proposal) { create(:proposal, with_procedures: [procedure]) }
  let(:enquiry) { create(:enquiry, :card_authorized, proposal: proposal) }

  describe 'advanced price validation' do
    before { create(:payment_request, enquiry: enquiry, price: 2500) }

    it 'should allow invoice with price less than proposed' do
      request = PaymentRequest.create(enquiry: enquiry, price: 2000)
      expect(request.errors.none?).to eq true
    end

    it 'should allow invoice with price equail to proposed' do
      request = PaymentRequest.create(enquiry: enquiry, price: 2500)
      expect(request.errors.none?).to eq true
    end

    it 'should not allow invoice with price grater than proposed' do
      request = PaymentRequest.create(enquiry: enquiry, price: 2600)
      has_error = request.errors.added?(:price, :less_than_or_equal_to, count: 2500)
      expect(has_error).to eq true
    end
  end

  describe 'updating enquiry state on create' do
    subject { create(:payment_request, enquiry: enquiry) }
    it { expect(subject.enquiry.workflow_state).to eq 'payment_requested' }
  end
end
