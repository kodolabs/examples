require 'rails_helper'

describe Notifications::Create do
  let!(:user) { create :user, :organiser }
  let(:event) { create :event, :active, creator: user }
  let!(:profile) { create :profile, :organiser, user: user, event: event }
  let(:form) { Notifications::NotificationForm.new(title: 'Title', text: 'Text') }
  let(:call) { Notifications::Create.call(form, event, user) }

  specify 'should create new notification' do
    expect { call }.to change(Notification, :count).by(1)
  end
end
