class DestroyPostWorker
  include Sidekiq::Worker

  def perform(post_id)
    Posts::Destroy.new(post_id).call
  end
end
