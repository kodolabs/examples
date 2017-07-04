require 'rails_helper'

describe Registrations::UpdateStatus do
  let(:user) { create :user, :organiser }
  let(:event) { create :event, :pending }
  let(:ticket_class) { create :ticket_class, event: event }
  let(:profile) { create :profile, :organiser, user: user, event: event }
  let(:ticket) { create :ticket, profile: profile, ticket_class: ticket_class }

  specify 'change registration status to inactive' do
    registration = create :registration, event: event, profile: profile, ticket: ticket, active: true
    Registrations::UpdateStatus.call(event)
    expect(registration.reload.active).to eq false
  end

  specify 'change registration status to active' do
    registration = create :registration, event: event, profile: profile, ticket: ticket, active: false
    event.update_attribute(:status, :active)
    Registrations::UpdateStatus.call(event)
    expect(registration.reload.active).to eq true
  end
end
