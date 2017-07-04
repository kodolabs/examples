require 'rails_helper'

feature 'Patient Payments Page' do
  let(:user)       { create :user }
  let!(:patient)   { create :patient, user: user }
  let!(:procedure) { create :procedure }
  let!(:demand)    { create :demand, patient: patient, procedures: [procedure] }
  let!(:enquiry)   { create :enquiry, :card_authorized, demand: demand }
  let!(:proposal)  { create :proposal, with_procedures: [procedure], enquiry: enquiry }

  before { user_sign_in user }

  context 'with list of payments' do
    before do
      request_first = PaymentRequest.create(created_at: '2013-01-01 00:00:00 -0500', enquiry: enquiry, price: 2600)
      request_second = PaymentRequest.create(created_at: '2015-01-01 00:00:00 -0500', enquiry: enquiry, price: 1000)
      _payment_first = Payment.create(created_at: '2013-01-02 00:00:00 -0500', payable: request_first, price: 2600)
      _payment_second = Payment.create(created_at: '2015-01-02 00:00:00 -0500', payable: request_second, price: 1000)
      visit patient_payments_path
    end

    it 'should show newest first' do
      payments = page.all('.payments__table-row')
      expect(payments.first).to have_content '02/01/15'
      expect(payments.last).to have_content '02/01/13'
    end
  end
end
