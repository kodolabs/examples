require 'rails_helper'

describe Inquiry do
  context 'send emails' do
    specify 'success' do
      mailer = double('mailer')
      allow(mailer).to receive(:deliver_later)
      expect(mailer).to receive(:deliver_later).twice
      expect(InquiryMailer).to receive(:notification).once.and_return(mailer)
      expect(InquiryMailer).to receive(:requester).once.and_return(mailer)
      create(:inquiry)
    end
  end
end
