require 'spec_helper'

describe Call do
  it "should have associations" do
    should have_many :rings
    should belong_to :account
    should belong_to :customer
    should belong_to :phone
    should belong_to :event
  end

  before do
    @account = Factory :account
  end

  describe "history of calls" do
    before do
      @customer = factory_object_for(@account, :customer)
      @calls = []
      (1..3).each do
        @calls << factory_object_for(@account, :call, :customer => @customer)
      end
      @call = factory_object_for(@account, :call, :customer => @customer)
      @calls << @call
    end

    it "should return list of calls" do
      result = Call.history(@call)
      result.length.should == (@calls.length - 1)
      result.should_not include @call
    end
  end


  describe "changing status" do
    before do
      @customer = factory_object_for(@account, :customer)
      @calls = []
      (1..3).each do
        @calls << factory_object_for(@account, :call, :customer => @customer)
      end

      @call = Call.first
      @user = @account.owner
    end

    it "should receive default status of :pending" do
      @call.status.should == "pending"
    end

    it "active scope should contain all pending calls" do
      Call.active.length.should == 3
    end

    it "should not unassign if it is not assigned" do
      lambda { @call.unassign_user }.should raise_error StateMachine::InvalidTransition
    end

    it "should not become assigned if no user assigned" do
      @call.assign
      @call.status.should == "pending"
    end

    it "should become assigned if user assigned" do
      @call.assign_user @user
      @call.status.should == "assigned"
    end

    it "should become pending if is assigned" do
      @call.assign_user @user
      @call.unassign_user
      @call.status.should == "pending"
    end

    it "should start ring if call is assigned" do
      @call.assign_user @user
      @call.start_call
      @call.status.should == "calling"
    end

    it "should become pending if call is calling" do
      @call.assign_user @user
      @call.start_call
      @call.finish_call false
      @call.status.should == "pending"
    end

    it "should become finished if call is calling" do
      @call.assign_user @user
      @call.start_call
      @call.finish_call true
      @call.status.should == "done"
    end

    it "should not become pending if status is finished" do
      @call.assign_user @user
      @call.start_call
      @call.finish_call true
      lambda { @call.finish_call false }.should raise_error StateMachine::InvalidTransition
      @call.status.should == "done"
    end

    it "active scope should contain assigned calls" do
      @call.assign_user @user
      Call.active.should include(@call)
    end

    it "active scope should contain calling calls" do
      @call.assign_user @user
      @call.start_call
      Call.active.should include(@call)
    end

    it "archived scope should not contain assigned calls" do
      @call.assign_user @user
      Call.archived.should_not include(@call)
    end

    it "archived scope should contain finished calls" do
      @call.assign_user @user
      @call.start_call
      @call.finish_call true
      Call.archived.should include(@call)
    end

    it "active scope should not contain finished calls" do
      @call.assign_user @user
      @call.start_call
      @call.finish_call true
      Call.active.should_not include(@call)
    end

    describe "reschedule" do

      before { @call.assign_user @user }

      it "should only be rescheduled if reschedule_at is set" do
        lambda { @call.reschedule! }.should raise_error StateMachine::InvalidTransition
      end

      it "can be rescheduled if rescheduled_at date is set" do
        @call.scheduled_at = Time.now.advance(:days => 1)
        expect { @call.reschedule! }.to change(@call, :status).to('pending')
      end
    end
  end

  describe "active scope" do
    before do
      @customer = factory_object_for(@account, :customer)

      @rescheduled_call = factory_object_for(@account, :call, :customer => @customer, :updated_at => Time.now)
      @rescheduled_call.scheduled_at = Time.now.advance(:hours => 24)
      @rescheduled_call.reschedule
    end

    it "should select pending call" do
      Timecop.freeze(Time.now.advance(:minutes => -10)) do
        @pending_call = factory_object_for(@account, :call, :customer => @customer, :updated_at => Time.now)
        @account.calls.active.scheduled.should include @pending_call
      end
    end

    it { @account.calls.active.scheduled.should_not include @rescheduled_call }
  end

  describe "pending scope" do
    before do
      @customer = factory_object_for(@account, :customer)
      @calls = []
      (1..3).each do |i|
        @calls << factory_object_for(@account, :call, :customer => @customer, :updated_at => Time.now + i.minutes)
      end
      @user = @account.owner
    end

    it "pending scope should return pending calls" do
      @calls[1].assign_user @user
      @calls[2].assign_user @user
      @calls[2].start_call
      Call.pending.length.should == 1
      Call.pending.should include(@calls[0])
    end
  end

  describe "assign pending call" do
    before do
      @customer = factory_object_for(@account, :customer)
      @user = @account.owner
    end

    it "should assign lateset pending call and return it" do
      (1..3).each do |i|
        factory_object_for(@account, :call, :customer => @customer, :updated_at => Time.now + i.minutes)
      end
      latest_call = Call.first
      assigned_call = Call.assign_pending_call @user

      assigned_call.should_not == nil
      assigned_call.id.should == latest_call.id
      assigned_call.user_id.should == @user.id
      assigned_call.status.should == "assigned"
    end

    it "should return nil if not calls pending" do
      assigned_call = Call.assign_pending_call @user
      assigned_call.should == nil
    end
  end
end
