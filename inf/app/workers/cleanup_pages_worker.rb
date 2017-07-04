class CleanupPagesWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    Pages::NotLinked.new.query.destroy_all
  end
end
