class MonitoringRecentPostsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(30) }

  def perform
    Page.owned.each { |page| RecentPostsWorker.perform_async(page.id) }
  end
end
