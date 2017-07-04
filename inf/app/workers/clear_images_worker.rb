class ClearImagesWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    ArticleImage.not_used.older_than_day.destroy_all
  end
end
