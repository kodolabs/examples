class UpdateMonitoringWorker
  include Sidekiq::Worker

  def perform(domain_id, type)
    domain = Domain.find(domain_id)
    Monitorings::Runner.new(domain.monitorings.by_type(type).first).call

    ActionCable.server.broadcast(
      "domain_#{domain_id}_update_#{type}",
      type: type.to_s
    )
    Subscribers::Jobs.new(domain_id, "update_#{type}").reset
  end
end
