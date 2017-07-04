class MonitoringTokensWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    Account.pluck(:id).each { |id| CheckTokenWorker.perform_async(id) }
  end
end
