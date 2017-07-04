class ShareWorker
  include Sidekiq::Worker

  def perform(share_id)
    Shares::Commands::Publish.new(share_id).call
  end
end
