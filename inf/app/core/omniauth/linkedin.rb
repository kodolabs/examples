class Omniauth::Linkedin < Omniauth::Base
  def initialize(user, request)
    auth_hash = request.env['omniauth.auth']
    @customer = user.customer
    @uid = auth_hash['uid']
    @info = auth_hash['info']
    @token = auth_hash['credentials']['token']
    expires_at = auth_hash['credentials'].try(:[], 'expires_at')
    @expires_at_value = expires_at ? Time.zone.at(expires_at) : nil

    @name = auth_hash['info']['name']
    @provider_id = Provider.linkedin.id
    @logo = auth_hash['info']['image']
  end

  def call
    check_if_allowed
    connect_account
  end
end
