class ImporterWorker
  include Sidekiq::Worker

  sidekiq_options queue: :pubsub

  def perform(msg)
    Importer.push msg
  end
end
