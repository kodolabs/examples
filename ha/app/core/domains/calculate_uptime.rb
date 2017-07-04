class Domains::CalculateUptime
  def initialize(domain, uptime_period)
    @domain = domain
    @uptime_period = uptime_period
    @monitoring = @domain.monitorings.uptime.first
  end

  def call
    return 0 if total.zero?
    ((success * 100.0) / total).round(1)
  end

  private

  def period_date
    Time.zone.today - @uptime_period
  end

  def total
    @total ||= @monitoring.histories.since(period_date).count
  end

  def success
    @monitoring.histories.success.since(period_date).count
  end
end
