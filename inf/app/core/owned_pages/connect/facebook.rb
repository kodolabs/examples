module OwnedPages
  module Connect
    class Facebook < ::OwnedPages::Connect::Base
      def call
        return broadcast(:invalid) if @form.invalid? || invalid_account?
        disconnect
        create
        broadcast(:ok)
      rescue Koala::Facebook::AuthenticationError
        return broadcast(:api_error)
      rescue AccountsLimitReachedException
        return broadcast(:limit)
      rescue OwnedPages::Connect::AccountPageDisconnected
        return broadcast(:disconnected)
      rescue => error
        raise_error(error)
        return broadcast(:api_error)
      end

      private

      def create
        return if @form.checked_pages.blank?
        @form.checked_pages.each do |checked_page|
          raise AccountsLimitReachedException if @customer.reached_account_limit?
          page = Page::FindOrCreateAndFetch.new(@provider.id, 'handle', checked_page['handle'],
            checked_page['uid']).call
          owned_page = connect_owned_page(page, checked_page['token'])
          InitialStatsWorker.perform_async(page.id)
          RecentPostsWorker.perform_async(page.id)
          Webhooks::Facebook::Create.new(owned_page.id).call
        end
      end
    end
  end
end
