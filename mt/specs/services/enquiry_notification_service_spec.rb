require 'rails_helper'

describe EnquiryNotificationService do
  let!(:enquiry) { create(:enquiry, :pending) }
  let!(:common_params) { ['pending', 'deliver_now', { '_aj_globalid' => enquiry.to_global_id.to_s }] }
  let!(:patient_job_params) { ['PatientNotificationMailer', common_params].flatten }
  let!(:manager_job_params) { ['ManagerNotificationMailer', common_params].flatten }

  it 'should use proper mailers' do
    EnquiryNotificationService.new(enquiry).send_email
    expect(ActionMailer::DeliveryJob).to have_been_enqueued.with(*patient_job_params)
    expect(ActionMailer::DeliveryJob).to have_been_enqueued.with(*manager_job_params)
  end
end
