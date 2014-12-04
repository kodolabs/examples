class Populars::HitWorker
  include Sidekiq::Worker

  def perform(model_name, id)
    Stats::Popular.hit model_name, id
  end
end
