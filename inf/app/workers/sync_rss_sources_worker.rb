class SyncRssSourcesWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    RssSource.find_each do |source|
      RssSource::SaveRssItems.new(source).perform
    end
  end
end
