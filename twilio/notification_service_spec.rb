require 'spec_helper'

describe NotificationService do
  let(:user)    { create :user }
  let(:message) { create :message, user: user }
  let(:service) { NotificationService.new }

  context "when user has email notifications turned on" do
    before do
      user.notify_by_email = true
      service.should_receive(:send_email_notification)
    end

    specify "new_message should send notification by email" do
      service.new_message(message)
    end
  end

  context "when user has sms notifications turned on" do
    before do
      user.notify_by_sms = true
      service.should_receive(:send_sms_notification)
    end

    specify "new_message should send notification by sms" do
      service.new_message(message)
    end
  end
end