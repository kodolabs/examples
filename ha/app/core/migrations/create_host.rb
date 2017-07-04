class Migrations::CreateHost
  include Interactor

  def call
    context.blog = context.domain.blog.clone
    context.params[:migrate_to_new_domain] ? migrate_to_new_domain : migrate_to_same_domain
  rescue => e
    context.fail!(message: e.message)
  end

  private

  def migrate_to_new_domain
    old_host = context.domain.host.clone
    @context = Migrations::ToNewDomain.new(context).call
    scan_host(context.new_domain)
    remove_articles(context.domain.reload.host || old_host) if context.params[:remove_articles]
  end

  def migrate_to_same_domain
    @context = Migrations::ToSameDomain.new(context).call
    scan_host(context.domain.reload)
  end

  def scan_host(domain)
    return unless domain&.host&.wordpress?
    WpHostScanWorker.perform_async(domain.host.id)
  end

  def remove_articles(host)
    return if host&.html?
    job_id = HostRemoveContentWorker.perform_async(host.id)
    Subscribers::Jobs.new(host.blog_id, 'sync_up').set(job_id)
  end
end
