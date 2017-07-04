class TrackFbAdAccountsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    Account.facebook.each do |account|
      Facebook::AdsAccountsService.new(account).update
    end
  end
end
