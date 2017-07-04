class CheckInvalidAccountsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(2) }
  INTERVAL = 1.week

  def perform
    invalid_accounts.each { |account| InvalidAccountEmailWorker.perform_async(account.customer_id) }
  end

  private

  def invalid_accounts
    notified_at_min = Time.current.utc.beginning_of_day - INTERVAL
    Account.connected.with_invalid_token
      .joins(:customer).where('customers.notified_at < ? OR customers.notified_at IS NULL', notified_at_min)
      .select(:customer_id).group(:customer_id)
  end
end
