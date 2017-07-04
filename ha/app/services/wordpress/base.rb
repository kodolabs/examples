class Wordpress::Base
  include Interactor
  attr_accessor :host, :domain, :context

  def initialize(context = {})
    @host = context.host
    @domain = context.host.domain
    @context = context
  end

  private

  def update_last_error(message = nil)
    @host.update(last_error: message)
  end
end
