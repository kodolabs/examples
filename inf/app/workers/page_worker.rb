class PageWorker
  include Sidekiq::Worker

  def perform(page_id)
    page = Page.find_by(id: page_id)
    SavePageInfo.new(page).call
  end
end
