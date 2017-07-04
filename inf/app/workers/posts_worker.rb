class PostsWorker
  include Sidekiq::Worker

  def perform(page_id, options = {})
    page = Page.find_by(id: page_id)
    SavePosts.new(page, options).call
    DeleteOutdatedPosts.new(page).call
  end
end
