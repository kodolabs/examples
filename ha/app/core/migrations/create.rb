class Migrations::Create < Rectify::Command
  def initialize(form, domain, user)
    @form = form
    @domain = domain
    @user = user
  end

  def call
    return broadcast(:invalid) if @form.invalid?
    service = Migrations::Run.call(domain: @domain, params: @form.attributes, user: @user)
    return broadcast(:invalid) if service.failure?
    domain = @form.migrate_to_new_domain ? service.new_domain : service.domain
    broadcast(:ok, domain)
  end
end
