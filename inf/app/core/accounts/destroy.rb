module Accounts
  class Destroy < Rectify::Command
    def initialize(account)
      @account = account
    end

    def call
      return unless @account
      disconnect_owned_pages
      disconnect_account
      remove_analytics
    end

    private

    def disconnect_account
      @account.update_attribute :customer_id, nil
    end

    def disconnect_owned_pages
      @account.owned_pages.update_all(account_id: nil)
    end

    def remove_analytics
      @account.analytics_configs.destroy_all
    end
  end
end
