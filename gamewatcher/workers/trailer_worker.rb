class TrailerWorker
  include Sidekiq::Worker

  def perform(model_name, id)
    Trailer::Store.store model_name, id
    Trailer::Analyze.count model_name, id
  end

end
