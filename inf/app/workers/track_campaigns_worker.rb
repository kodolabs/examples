class TrackCampaignsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    Campaign.all.each do |campaign|
      Facebook::TrackCampaignService.new(campaign).call
    end
  end
end
