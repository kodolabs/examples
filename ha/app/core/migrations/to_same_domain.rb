class Migrations::ToSameDomain < Migrations::Base
  def call
    Domain.transaction do
      old_host = deactivate_old_host
      new_host = create_new_host(context.domain)
      old_host.update!(migrated_to: new_host.id)
    end
    context
  end
end
