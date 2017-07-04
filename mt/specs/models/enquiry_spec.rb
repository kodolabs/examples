require 'rails_helper'

describe Enquiry do
  it { should belong_to(:demand) }
  it { should belong_to(:hospital) }
  it { should have_one(:proposal) }
  it { should have_many(:payment_requests) }

  describe 'declining enquiry' do
    let(:enquiry) { create(:enquiry, :pending) }

    it 'should transit on not empty reason' do
      expect(enquiry.decline_enquiry!('some reason')).to be true
      expect(enquiry.errors.any?).to be false
      expect(enquiry.state_comment).to eq 'some reason'
    end

    it 'should fail on empty reason' do
      expect(enquiry.decline_enquiry!('')).to be false
      expect(enquiry.errors.any?).to be true
    end
  end

  describe 'showing patient contact details' do
    let!(:enquiry) { create :enquiry, :payment_requested }
    let!(:proposal) { create :proposal, with_procedures: [(create :procedure)], enquiry: enquiry }

    before do
      proposal.update_column(:price, 1234)
    end

    it 'should change status if 10% payment is made' do
      request = create :payment_request, price: 124, enquiry: enquiry
      create :payment, price: 124, payable: request

      expect(enquiry.reveal_contact_details).to eq true
    end

    it 'should not change status if there are no payments' do
      enquiry.complete_payment!

      expect(enquiry.reveal_contact_details).to eq false
    end

    it 'should not change status if payment is not sufficient' do
      request = create :payment_request, price: 123, enquiry: enquiry
      create :payment, price: 123, payable: request

      expect(enquiry.reveal_contact_details).to eq false
    end
  end

  describe 'notifications' do
    let!(:demand) { create(:demand, hospitals: []) }
    let!(:hospital) { create(:hospital) }
    subject { create(:enquiry, :pending, demand: demand, hospital: hospital) }

    it 'should send notification on state change' do
      subject
      expect_any_instance_of(EnquiryNotificationService).to receive(:send_email)
      subject.cancel_enquiry!
    end

    it 'should send notification on plus upgrade' do
      subject
      expect_any_instance_of(EnquiryNotificationService).to receive(:send_email)
      subject.charge_action
    end
  end

  describe 'reminders' do
    let!(:demand) { create(:demand, hospitals: []) }
    let!(:hospital) { create(:hospital) }
    let!(:enquiry_attrs) { { demand: demand, hospital: hospital } }

    it 'should schedule reminder on pending' do
      enquiry = create(:enquiry, :preop, enquiry_attrs)
      expect_any_instance_of(ReminderService).to receive(:schedule)
      enquiry.preop_created!
    end

    it 'should schedule reminder on propose' do
      enquiry = create(:enquiry, :pending, enquiry_attrs)
      expect_any_instance_of(ReminderService).to receive(:schedule)
      enquiry.make_proposal!
    end

    it 'should schedule reminder on card authorization' do
      enquiry = create(:enquiry, :proposal_accepted, enquiry_attrs)
      expect_any_instance_of(ReminderService).to receive(:schedule)
      enquiry.authorize_card!
    end

    it 'should schedule reminder on first payment completion' do
      enquiry = create(:enquiry, :payment_requested, enquiry_attrs)
      create(:proposal, enquiry: enquiry, price: 100.0)
      create(:payment_request, enquiry: enquiry)

      expect_any_instance_of(ReminderService).to receive(:schedule)
      enquiry.complete_payment!
      create(:payment_request, enquiry: enquiry)
      enquiry.complete_payment!
    end
  end

  describe '#param_event' do
    let!(:enquiry) { create(:enquiry, :pending) }

    it 'should send event if it is possible for current state' do
      enquiry.param_event('cancel_enquiry!')

      expect(enquiry.workflow_state).to eq('enquiry_cancelled')
    end

    it 'should do nothing if event is impossible' do
      enquiry.param_event('harmful_method')

      expect(enquiry.workflow_state).to eq('pending')
    end
  end

  describe '#all_payments' do
    let!(:enquiry) { create(:enquiry, :payment_requested) }

    it 'should return all kinds of payments' do
      create :proposal, enquiry: enquiry
      plus_payment = create :payment, payable: enquiry
      request = create :payment_request, enquiry: enquiry
      regular_payment = create :payment, payable: request

      expect(enquiry.all_payments).to eq([regular_payment, plus_payment])
    end
  end
end
