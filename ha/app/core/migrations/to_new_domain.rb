class Migrations::ToNewDomain < Migrations::Base
  def call
    @context.new_domain = Domain.find(context.params[:domain_id])
    Domain.transaction do
      new_host = create_new_host(context.new_domain)
      update_old_host(new_host)
      update_old_domain_status
    end
    context
  end

  private

  def update_old_host(host)
    action = context.params[:host_action]&.to_sym
    deactivate_old_host(host)
    clone_host_with_empty_blog(context.domain.host) if action == :empty_blog
  end

  def clone_host_with_empty_blog(old_host)
    Hosts::CloneHost.new(context.domain, old_host).call
  end
end
