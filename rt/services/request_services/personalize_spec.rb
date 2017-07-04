require 'rails_helper'

describe RequestServices::Personalize do
  let(:customer) { create :customer, business_name: 'Business' }
  describe '#call' do
    it 'replace all %USER_NAME%' do
      options = {
        subject: '%USER_NAME% - %USER_NAME% - %USER_NAME%',
        body: '%USER_NAME% - %USER_NAME% - %USER_NAME% - %USER_NAME%',
        sender_name: 'sender_name',
        customer: customer
      }
      request = create :request, options
      personalized = RequestServices::Personalize.new(request).call
      expect(personalized[:body]).to eq 'Business - Business - Business - Business'
      expect(personalized[:subject]).to eq 'Business - Business - Business'
    end

    it 'replace all %LOCATION_NAME%' do
      location = create :location, name: 'loc', customer: customer
      options = {
        subject: '%LOCATION_NAME% - %LOCATION_NAME% - %LOCATION_NAME%',
        body: '%LOCATION_NAME% - %LOCATION_NAME% - %LOCATION_NAME% - %LOCATION_NAME%',
        location: location, customer: customer
      }
      request = create :request, options
      personalized = RequestServices::Personalize.new(request).call
      expect(personalized[:body]).to eq 'loc - loc - loc - loc'
      expect(personalized[:subject]).to eq 'loc - loc - loc'
    end

    it 'replace line separators' do
      request = create :request, subject: 'some subject', body: "sdasgdgasd\nhfhdsgfsd\nsgdsg\nhfhsdgfhsd", customer: customer, sender_name: 'Sender Name', sender_email: 'some@email.com'
      personalized = RequestServices::Personalize.new(request).call
      expect(personalized[:body]).to eq "sdasgdgasd\nhfhdsgfsd\nsgdsg\nhfhsdgfhsd"
      expect(personalized[:subject]).to eq 'some subject'
      expect(personalized[:from]).to eq '"Sender Name" <some@email.com>'
    end

    context 'when request has SMS send method' do
      let(:sms_template) { create(:sms_template, customer: customer) }
      let(:feedback_request) { create(:sms_request, customer: customer, sms_template: sms_template) }
      let!(:request_invitation) { create(:request_invitation, request: feedback_request) }
      let(:expected_result) do
        {
          number: request_invitation.contact,
          message: feedback_request.body
        }
      end

      subject { described_class.new(feedback_request, request_invitation).call }

      it { is_expected.to eq(expected_result) }
    end
  end
end
