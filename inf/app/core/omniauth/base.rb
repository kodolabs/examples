class Omniauth::Base
  protected

  def check_if_allowed
    raise AccountsLimitReachedException if @customer.reached_account_limit?
    raise AccountIsNotUniqException if Account.connected.where(uid: @uid, provider_id: @provider_id).any?
  end

  def connect_account
    Accounts::Connect.new(@customer, uid: @uid,
                                     token: @token,
                                     provider_id: @provider_id,
                                     name: @name,
                                     expires_at: @expires_at_value,
                                     logo: @logo).query
  end
end
