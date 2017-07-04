class Omniauth::Google
  def initialize(user, request)
    @user = user
    @customer = user.customer
    request = request
    auth_hash = request.env['omniauth.auth']
    @uid = auth_hash['uid']
    @token = auth_hash['credentials']['token']
    @refresh_token = auth_hash['credentials']['refresh_token']
    expires_at = auth_hash['credentials'].try(:[], 'expires_at')
    @expires_at_value = expires_at ? Time.zone.at(expires_at) : nil

    @name = auth_hash['info']['name']
    @username = auth_hash['info']['email'].split('@').first
    @logo = auth_hash['info'].try(:[], 'image')
    @provider_id = Provider.google.id
  end

  def call
    check_if_allowed
    connect_account
    @account
  end

  private

  def connect_account
    @account = Accounts::Connect.new(@customer, uid: @uid,
                                                token: @token,
                                                provider_id: @provider_id,
                                                name: @name,
                                                username: @username,
                                                logo: @logo,
                                                refresh_token: @refresh_token,
                                                expires_at: @expires_at_value).query
  end

  def check_if_allowed
    raise AccountsLimitReachedException if @customer.reached_account_limit?
    raise AccountIsNotUniqException if Account.connected.where(uid: @uid, provider_id: @provider_id).any?
  end
end
