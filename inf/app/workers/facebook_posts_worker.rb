class FacebookPostsWorker
  include Sidekiq::Worker

  def perform(page_id)
    page = Page.find_by(id: page_id)
    Facebook::SavePosts.new(page).call
  end
end
