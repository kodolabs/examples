class PageStatsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  BATCH_LIMIT = 100

  def perform
    fetch_facebook_stats
    fetch_twitter_stats
  end

  private

  def fetch_facebook_stats
    Page.facebook.owned.each do |page|
      StatsWorker.perform_async(page_id: page.id, provider: 'facebook')
    end
  end

  # Fetch twitter stats in bulk for reducing api calls
  # https://dev.twitter.com/rest/reference/get/users/lookup

  def fetch_twitter_stats
    Page.twitter.owned.find_in_batches(batch_size: BATCH_LIMIT) do |page_group|
      handles = page_group.pluck(:handle)
      StatsWorker.perform_async(handles: handles, provider: 'twitter')
    end
  end
end
