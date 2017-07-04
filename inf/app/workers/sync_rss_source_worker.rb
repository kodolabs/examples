class SyncRssSourceWorker
  include Sidekiq::Worker

  def perform(source_id)
    rss_source = RssSource.find(source_id)
    RssSource::SaveRssItems.new(rss_source).perform
  end
end
