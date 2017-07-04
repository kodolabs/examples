class DestroyShareWorker
  include Sidekiq::Worker

  def perform(share_id)
    Shares::Commands::Destroy.new(share_id).call
  end
end
