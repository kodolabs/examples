class InitialStatsWorker
  include Sidekiq::Worker

  def perform(page_id)
    page = Page.find_by(id: page_id)

    Facebook::FetchStats.new(page).call
  end
end
