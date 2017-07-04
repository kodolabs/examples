require 'rails_helper'

describe NotificationStatusWorker do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :active }
  let(:notification) { create :notification, event: event }
  let(:ticket_class) { create :ticket_class, event: event }
  let(:first_profile) { create :profile, :organiser, surname: 'Alex', user: user, event: event }
  let(:first_ticket) { create :ticket, profile: first_profile, ticket_class: ticket_class }
  let!(:first_registration) { create :registration, event: event, profile: first_profile, ticket: first_ticket }
  let(:second_profile) { create :profile, :organiser, surname: 'Alex', user: user, event: event }
  let(:second_ticket) { create :ticket, profile: second_profile, ticket_class: ticket_class }
  let!(:second_registration) { create :registration, event: event, profile: second_profile, ticket: second_ticket }

  it 'should retry correctly if one of refunds fails' do
    expect(NotificationStatus.count).to eq(0)
    described_class.new.perform(notification.id)
    expect(NotificationStatus.count).to eq(2)
  end
end
