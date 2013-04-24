require 'spec_helper'

describe User do

  it { should have_many :phones }
  it { should have_many :messages }
  it { should have_many :greetings }

  specify "can be not an admin" do
    user = User.new admin: '0'
    user.role.should == ''
  end

  specify "can be an admin" do
    user = User.new admin: '1'
    user.role.should == 'admin'
  end

  specify "#admin" do
    user = User.new admin: '0'
    user.admin.should == '0'
  end

  specify "add_phone" do
    Phone.stub(:purchase).and_return(build :phone, sid: '111', number: '+545')
    user = create :user
    expect { user.add_phone('NZ') }.to change(user.phones, :count).by(1)
  end

  describe "greeting" do
    context "when there is active greeting" do
      before do
        @user = create :user
        @greeting = create :greeting, user: @user
        @active_greeting = create :greeting, user: @user, active: true
      end

      specify do
        @user.greeting.should == @active_greeting
      end
    end

    context "when there are no greetings" do
      specify { create(:user).greeting.should be_nil }
    end
  end

  describe "scheduled_greeting" do
    before do
      @user = build :user
    end

    context "when there are no scheduled greetings" do
      specify "should return nil" do
        Schedule.stub(:active).and_return(nil)
        @user.scheduled_greeting.should be_nil
      end
    end

    context "scheduled greeting exists" do
      before do
        @greeting = mock 'Greeting'
        @schedule = mock_model 'Schedule', greeting: @greeting
        Schedule.stub(:active).and_return([@schedule])
      end

      specify "should return scheduled greeting" do
        @user.scheduled_greeting.should == @greeting
      end
    end
  end
end
