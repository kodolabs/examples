require 'rails_helper'

describe Inquires::Create do
  context 'success' do
    let(:valid_params) do
      {
        inquiry: {
          username: 'Username',
          email: 'email@mail.com',
          company: 'Company',
          phone: '+380505550050',
          ahpra: 'ATS1231231231'
        }
      }
    end
    let(:valid_form) { Inquires::InquiryForm.from_params(valid_params) }

    specify 'create inquiry' do
      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(InquiryMailer).to receive(:notification).and_return(message_delivery)
      expect(InquiryMailer).to receive(:requester).and_return(message_delivery)
      expect(message_delivery).to receive(:deliver_later).twice
      expect { Inquires::Create.call(valid_form) }.to change(Inquiry, :count).to(1)
    end
  end
end
