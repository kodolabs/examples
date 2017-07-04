module Migrations
  class Base
    attr_accessor :context

    def initialize(context)
      @context = context
    end

    private

    def create_new_host(domain)
      Hosts::CreateHost.new(domain, host_params).call
    end

    def update_old_domain_status
      context.domain.update!(status: context.params[:status])
    end

    def host_params
      context.params.slice(:blog_type).merge(blog_id: context.domain.host.blog_id)
    end

    def deactivate_old_host(new_host = nil)
      params = {
        active: false,
        migrated_to: new_host&.id
      }
      if context.params[:reason].present?
        params[:reason] = I18n.t('migrations.messages.reason', reason: context.params[:reason])
      end
      context.domain.host.update!(params)
      context.domain.host
    end
  end
end
