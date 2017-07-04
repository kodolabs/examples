module Shares
  module Commands
    class DestroyTwitter
      def initialize(publication)
        @publication = publication
      end

      def call
        return if account.blank?
        client.destroy_tweet(@publication.uid)
      rescue Twitter::Error::NotFound
        return false
      end

      private

      def client
        @client ||= ::Twitter::Service.new(account).client
      end

      def account
        @account ||= @publication.owned_page.account
      end
    end
  end
end
