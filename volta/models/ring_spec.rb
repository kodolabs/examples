require 'spec_helper'

describe Ring do
  it "should have associations" do
    should belong_to :call
    should belong_to :user
  end

  it "should have validations" do
    should validate_presence_of :call_id
    should validate_presence_of :user_id
  end

  it "should have default status" do
    @call = factory_object_for(nil, :call)
    @ring = Factory :ring, :call => @call
    @ring.status.should == Ring::DEFAULT_STATUS
  end

  it "should have :today scope" do
    @call = factory_object_for(nil, :call)
    @old_call = Factory :ring, :created_at => Time.now - 2.days, :call => @call
    @ring = Factory :ring, :call => @call

    Ring.today.should == [@ring]
  end

  describe "twilio integration" do

    let(:ring) { Factory :ring }

    describe "initiate a conference call" do
      let(:start_a_conference)  { ring.init_conference_call('callback_uri') }

      before {
        stub_request(:post, /api.twilio.com/).
           to_return(:status => 200, :body => '{"sid":"CA5f587f4f999b5d5857588f48e8f1c170","date_created":"Mon, 02 May 2011 14:25:36 +0000","date_updated":"Mon, 02 May 2011 14:25:36 +0000","parent_call_sid":null,"account_sid":"ACc1da5116033777e569a7e0fcfa722396","to":"+380692403932","from":"+15127367648","phone_number_sid":"PNf316ce1ac4df632512c68dade8303f2f","status":"queued","start_time":null,"end_time":null,"duration":null,"price":null,"direction":"outbound-api","answered_by":null,"api_version":"2010-04-01","annotation":null,"forwarded_from":null,"group_sid":null,"caller_name":null,"uri":"\/2010-04-01\/Accounts\/ACc1da5116033777e569a7e0fcfa722396\/Calls\/CA5f587f4f999b5d5857588f48e8f1c170.json","subresource_uris":{"notifications":"\/2010-04-01\/Accounts\/ACc1da5116033777e569a7e0fcfa722396\/Calls\/CA5f587f4f999b5d5857588f48e8f1c170\/Notifications.json","recordings":"\/2010-04-01\/Accounts\/ACc1da5116033777e569a7e0fcfa722396\/Calls\/CA5f587f4f999b5d5857588f48e8f1c170\/Recordings.json"}}', :headers => {})
      }

      it "should create two conversations" do
        expect { start_a_conference }.to change(Conversation, :count).by(2)
        ring.status.should == 'init'
      end
    end
  end
end
