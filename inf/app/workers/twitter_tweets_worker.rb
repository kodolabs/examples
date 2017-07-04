class TwitterTweetsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5

  def perform(page_id)
    page = Page.find_by(id: page_id)
    Twitter::SaveTweets.new(page).call
  end
end
