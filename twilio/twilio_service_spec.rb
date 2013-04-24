require 'spec_helper'

describe TwilioService do
  let(:service) { TwilioService.new }
  let(:user)    { create :user }
  let(:phone)   { create :phone, number: '+222', user: user }

  let(:incoming_params)   { { "Called"=>"+222", "To"=>"+222", "Caller"=>"+111", "CallSid"=>"CA81e9321eb6d013bf813c83b99dc2d495", "From"=>"+111" } }
  let(:recording_params)  { { "RecordingUrl"=>"http://api.twilio.com/2010-04-01/Accounts/AC8d43d4070755495e82621183837b7bf2/Recordings/RE1a1cecbde7eb5facba9a2ca22540a5bf", "Called"=>"+222", "To"=>"+222",  "RecordingDuration"=>"1", "Caller"=>"+111", "RecordingSid"=>"RE1a1cecbde7eb5facba9a2ca22540a5bf", "CallSid"=>"CA32db99e7c49dd83644748ceb65221705", "From"=>"+111", "controller"=>"calls", "action"=>"recording"} }
  let(:transcribe_params) { { "RecordingUrl"=>"http://api.twilio.com/2010-04-01/Accounts/AC8d43d4070755495e82621183837b7bf2/Recordings/RE1a1cecbde7eb5facba9a2ca22540a5bf", "To"=>"+222", "Called"=>"+222", "TranscriptionText"=>"(blank)", "Caller"=>"+111", "TranscriptionStatus"=>"completed", "CallSid"=>"CA32db99e7c49dd83644748ceb65221705", "From"=>"+111", "controller"=>"calls", "action"=>"transcribe"} }
  let(:status_params)     { { "Called"=>"+222", "To"=>"+222", "CallDuration"=>"4", "Caller"=>"+111", "Duration"=>"1", "CallSid"=>"CA81e9321eb6d013bf813c83b99dc2d495", "From"=>"+111" } }

  specify 'it should initialize a twilio client' do
    service.twilio.should be_a TwilioClient
  end

  describe 'incoming call' do
    context "when incoming phone number does not exist" do
      specify "should respond with error" do
        service.incoming_call({'To' => '123'}).should =~ /<Say voice="woman">Wrong number<\/Say>/
      end
    end

    context 'when phone number is properly configured' do
      before { phone }
      specify "be prompted to record a message" do
        response = service.incoming_call(incoming_params)
        response.should =~ /<Say voice="woman">Please leave a message after the beep<\/Say>/
        response.should =~ /<Record action="http:\/\/test.org\/calls\/record" transcribeCallback="http:\/\/test.org\/calls\/transcribe" maxLength="120"\/>/
      end
    end

    context 'when user has configured a greeting' do
      before do
        phone
        @greeting = create :greeting, user: user
        Greeting.any_instance.stub_chain(:record, :url).and_return('/greeting.url')
      end

      specify 'should play recorded greeting' do
        response = service.incoming_call(incoming_params)
        response.should =~ /<Play>\/greeting.url<\/Play>/
        response.should =~ /<Record action="http:\/\/test.org\/calls\/record" transcribeCallback="http:\/\/test.org\/calls\/transcribe" maxLength="120"\/>/
      end
    end
  end

  describe 'record' do
    before { phone }

    subject { service.record(recording_params) }

    specify 'should hangup the call' do
      should =~ /<Hangup\/>/
    end

    specify 'should create a message' do
      expect { subject }.to change(Message, :count).by(1)
    end

    specify 'message should belong to user' do
      subject
      Message.last.user.should == user
    end
  end

  describe 'transcribe' do
    before do
      phone
      @message = create :message, user: user, callsid: 'CA32db99e7c49dd83644748ceb65221705'
      NotificationService.any_instance.should_receive(:new_message).with(@message)
    end

    specify do
      service.transcribe(transcribe_params)
      @message.reload.transcription.should == '(blank)'
      @message.status.should == 'transcribed'
    end
  end

end
