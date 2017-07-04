class WatchdogWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(10) }

  INTERVAL = 6.hours

  def perform
    Page.where('last_crawled_at < ?', INTERVAL.ago).pluck(:id).each do |id|
      PostsWorker.perform_async(id)
    end

    page_ids = Page.twitter.pluck(:id) + Page.facebook.not_owned.pluck(:id)
    Page.where(id: page_ids).where('last_updated_at < ?', INTERVAL.ago).pluck(:id).each do |id|
      PageWorker.perform_async(id)
    end
  end
end
