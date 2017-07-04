class RemoveDemoPostsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    Share.demo.pluck(:id).each { |id| destroy(id) }
  end

  private

  def destroy(share_id)
    DestroyShareWorker.perform_async(share_id)
  end
end
