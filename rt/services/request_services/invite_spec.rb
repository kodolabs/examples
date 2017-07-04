require 'rails_helper'

module RequestServices
  RSpec.describe Invite do
    let(:customer) { create(:customer) }
    let(:instance) { described_class.new(feedback_request.id) }

    describe '#call' do
      subject { instance.call }

      context 'when send method is Sms' do
        let(:feedback_request) { create(:sms_request, customer: customer, sms_template: sms_template) }
        let(:sms_template) { create(:sms_template, customer: customer) }

        it do
          expect(SmsService).to receive(:send_later)
            .exactly(feedback_request.participants.count).times
            .and_return(true)
        end

        after { subject }
      end

      context 'when send method is Email' do
        let(:feedback_request) { create(:request, customer: customer) }
        let(:fake_service) { double(deliver_later: true) }

        it do
          expect(FeedbackRequestEmails).to receive(:invite)
            .exactly(feedback_request.participants.count).times
            .and_return(fake_service)
        end

        after { subject }
      end
    end
  end
end
