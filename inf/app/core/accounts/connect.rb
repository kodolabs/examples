module Accounts
  class Connect < Rectify::Query
    def initialize(customer, options)
      @customer = customer
      @uid = options[:uid]
      @provider_id = options[:provider_id]
      @token = options[:token]
      @username = options[:username]
      @name = options[:name]
      @expires_at = options[:expires_at]
      @secret = options[:secret]
      @logo = options[:logo]
      @refresh_token = options[:refresh_token]
    end

    def query
      Account.transaction do
        account = Account.find_or_create_by(uid: @uid, provider_id: @provider_id)
        account.active = true
        account.token = @token
        account.secret = @secret
        account.name = @name
        account.username = @username
        account.expires_at = @expires_at
        account.customer = @customer
        account.logo = @logo
        account.refresh_token = @refresh_token
        account.save

        if Provider.facebook.id == @provider_id
          Facebook::AdsAccountsService.new(account).update
        end

        account
      end
    end
  end
end
