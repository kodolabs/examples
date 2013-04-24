require 'spec_helper'

describe TwilioClient do
  let(:twilio_client) { TwilioClient.new }

  specify 'it should initialize a twilio client' do
    twilio_client.client.should be_a Twilio::REST::Client
  end

  context '#purchase_number', :vcr => {} do
    before do
      twilio_client.should_receive(:find_available_number).with('NZ').and_return(TwilioClient::TWILIO_TEST_NUMBER)
    end

    specify 'should get a number' do
      number = twilio_client.purchase_number 'NZ', 'http://example.org/callback', 'http://example.org/callback'
      number.should be_a Twilio::REST::IncomingPhoneNumber
    end
  end

  describe 'greeting' do
    context 'when phone number is properly configured' do
      specify "be prompted to record a message" do
        response = twilio_client.greeting(nil, 'record_callback', 'transcribe_callback')
        response.should =~ /<Say voice="woman">Please leave a message after the beep<\/Say>/
        response.should =~ /<Record action="record_callback" transcribeCallback="transcribe_callback" maxLength="120"\/>/
      end
    end

    context 'when user has configured a greeting' do
      specify 'should play recorded greeting' do
        response = twilio_client.greeting('record_url', 'record_callback', 'transcribe_callback')
        response.should =~ /<Play>record_url<\/Play>/
        response.should =~ /<Record action="record_callback" transcribeCallback="transcribe_callback" maxLength="120"\/>/
      end
    end
  end
end