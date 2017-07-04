require 'rails_helper'

describe Shares::Commands::Destroy do
  let(:command) { Shares::Commands::Destroy }
  let(:notify_service) { Notifications::Show }
  let(:job_service) { Sidekiq::ScheduledSet }

  context 'success' do
    context 'linkedin' do
      let(:share) { create(:share, :linkedin, :facebook) }

      specify 'linkedin page and not only linkedin' do
        allow_any_instance_of(notify_service).to receive(:call)
        expect_any_instance_of(job_service).to receive(:find_job).with(share.job_id).once
        expect_any_instance_of(notify_service).to receive(:call).once
        command.new(share).call
        expect(Share.count).to eq(0)
      end
    end
  end
end
