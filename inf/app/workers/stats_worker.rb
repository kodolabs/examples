class StatsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  def perform(options)
    Page::SaveStats.new(options).call
  end
end
