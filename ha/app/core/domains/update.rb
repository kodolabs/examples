module Domains
  class Update < Rectify::Command
    def initialize(form, domain)
      @form = form
      @domain = domain
    end

    def call
      @form.name_servers = split_name_servers(@form.name_servers)
      return broadcast(:invalid) if @form.invalid?
      return broadcast(:invalid) unless update_domain(@form, @domain)
      broadcast(:ok)
    end

    private

    def update_domain(form, domain)
      form.attributes = form.attributes.without(:status) if form.status == 'active'
      Domain.transaction do
        domain.update!(form.attributes)
        domain.activate! if form.status == 'active'
      end
      true
    end

    def split_name_servers(name_servers)
      name_servers.split(/\r\n/).map(&:strip)
    end
  end
end
