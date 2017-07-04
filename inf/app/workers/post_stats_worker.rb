class PostStatsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    save_twitter_stats
  end

  private

  def save_twitter_stats
    Page.twitter.owned.pluck(:id).each do |id|
      PostsWorker.perform_async(id, 'save_history' => true)
    end
  end
end
