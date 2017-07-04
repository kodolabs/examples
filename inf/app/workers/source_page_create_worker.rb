class SourcePageCreateWorker
  include Sidekiq::Worker

  def perform(options)
    SourcePages::Sync.new(options).call
  end
end
