module Facebook
  class AdsAccountsService
    def initialize(account)
      @account = account
    end

    def update
      @account.update_column(:fb_ad_accounts, ad_accounts.to_json)
    end

    private

    def ad_accounts
      graph.get_connection(
        @account.uid, 'adaccounts', fields: %i(id name account_status)
      )
        .select { |d| d['account_status'] == 1 }
        .map { |d| d.slice('id', 'name') }
        .map(&:values).to_h
    rescue Koala::Facebook::ClientError
      return {}
    end

    private

    def graph
      @graph ||= Koala::Facebook::API.new(@account.token)
    end
  end
end
