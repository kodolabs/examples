module Shares
  class ChangeSchedule < Rectify::Command
    def initialize(share, new_schedule)
      @share = share
      @new_schedule = Time.zone.parse(new_schedule)
    end

    def call
      return broadcast(:already_posted) if already_posted?
      return broadcast(:old_date) if Time.current > @new_schedule
      save
      broadcast(:ok)
    end

    private

    def already_posted?
      return true if @share.job_id.blank?
      @job = Sidekiq::ScheduledSet.new.find_job(@share.job_id)
      return true if @job.blank? || @share.expired?
      false
    end

    def save
      @share.update_column(:scheduled_at, @new_schedule)
      @job.reschedule(@share.scheduled_at)
    end
  end
end
