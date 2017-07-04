require 'rails_helper'

describe Shares::ChangeSchedule do
  let(:command) { Shares::ChangeSchedule }
  let(:sidekiq_set) { Sidekiq::ScheduledSet }
  let(:new_schedule) { (Time.current + 3.days + 12.hours + 3.minutes).change(sec: 0) }
  let(:formatted_date) { new_schedule.strftime('%d/%m/%Y %I:%M %p') }

  context 'success' do
    let(:share) { create(:share, :scheduled) }

    specify 'reschedule' do
      job = double('sidekiq job')
      allow(job).to receive(:reschedule).once.with(new_schedule)
      expect(job).to receive(:reschedule).once.with(new_schedule)

      allow_any_instance_of(sidekiq_set).to receive(:find_job).with(share.job_id).and_return(job)
      expect_any_instance_of(sidekiq_set).to receive(:find_job).with(share.job_id).and_return(job)

      command.new(share, formatted_date).call
      expect(share.reload.scheduled_at).to eq(new_schedule)
    end
  end

  context 'fail' do
    let(:share1) { create(:share, job_id: nil) }
    let(:share2) { create(:share) }
    let(:share3) { create(:share, :expired) }
    let(:old_date) { Time.zone.now - 2.days }
    let(:old_formmated_date) { old_date.strftime('%d/%m/%Y %I:%M %p') }

    context 'already posted' do
      specify 'not sheduled post' do
        job = double('sidekiq job')
        expect(job).not_to receive(:reschedule)

        command.new(share1, formatted_date).call
        expect(share1.reload.scheduled_at).not_to eq(new_schedule)
      end

      specify 'scheduled but posted some miliseconds ago' do
        allow_any_instance_of(sidekiq_set).to receive(:find_job).with(share2.job_id).and_return(false)
        expect_any_instance_of(sidekiq_set).to receive(:find_job).once
        command.new(share2, formatted_date).call
        expect(share2.reload.scheduled_at).not_to eq(new_schedule)
      end
    end

    specify 'scheduled, but already posted' do
      job = double('sidekiq job')
      expect(job).not_to receive(:reschedule)

      allow_any_instance_of(sidekiq_set).to receive(:find_job).with(share3.job_id).and_return(job)
      expect_any_instance_of(sidekiq_set).to receive(:find_job).with(share3.job_id).and_return(job)

      command.new(share3, formatted_date).call
      expect(share3.reload.scheduled_at).not_to eq(new_schedule)
    end

    specify 'reschedule to past' do
      job = double('sidekiq job')
      expect(job).not_to receive(:reschedule)

      allow_any_instance_of(sidekiq_set).to receive(:find_job).with(share2.job_id).and_return(job)
      expect_any_instance_of(sidekiq_set).to receive(:find_job).with(share2.job_id).and_return(job)

      command.new(share2, old_formmated_date).call
      expect(share2.reload.scheduled_at).not_to eq(old_date)
    end
  end
end
