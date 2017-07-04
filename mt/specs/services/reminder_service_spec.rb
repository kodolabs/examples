require 'rails_helper'

describe ReminderService do
  it 'should schedule proper jobs' do
    enquiry = create(:enquiry, :preop)
    enquiry.preop_created!
    expect(ManagerRequestReminderJob).to have_been_enqueued.with(enquiry.id)
  end
end
