require 'rails_helper'

describe Inquires::InquiryForm do
  let(:form) { Inquires::InquiryForm }
  let(:inquiry) { create(:inquiry) }

  context 'validation' do
    let(:valid_params) do
      {
        inquiry: {
          username: 'Username',
          email: 'email@mail.com',
          phone: '+380505550050',
          confirm_ahpra: '1',
          confirm_terms: '1'
        }
      }
    end

    def params(attrs = {})
      valid_params.deep_merge(inquiry: attrs)
    end

    specify 'valid with valid params' do
      expect(form.from_params(valid_params).valid?).to be_truthy
    end

    specify 'email uniqueness' do
      inquiry
      p = params(email: inquiry.email)
      expect(form.from_params(p).valid?).to be_falsy
    end
  end
end
