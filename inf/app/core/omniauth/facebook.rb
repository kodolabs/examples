class Omniauth::Facebook < Omniauth::Base
  def initialize(user, request)
    auth_hash = request.env['omniauth.auth']
    @customer = user.customer
    @uid = auth_hash['uid']
    @token = auth_hash['credentials']['token']
    expires_at = auth_hash['credentials'].try(:[], 'expires_at')
    @expires_at_value = expires_at ? Time.zone.at(expires_at) : nil
    @name = auth_hash['info']['name']
    @provider_id = Provider.facebook.id
    @logo = auth_hash['info']['image']
  end

  def call
    connect_account
  end
end
