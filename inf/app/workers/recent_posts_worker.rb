class RecentPostsWorker
  include Sidekiq::Worker

  def perform(page_id)
    RecentPosts.new(page_id).call
  end
end
