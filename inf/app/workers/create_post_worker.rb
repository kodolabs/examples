class CreatePostWorker
  include Sidekiq::Worker

  def perform(uid, handle)
    page = Pages::Create::Base.new(handle).call
    Posts::Create::Base.new(uid, page).call
  end
end
