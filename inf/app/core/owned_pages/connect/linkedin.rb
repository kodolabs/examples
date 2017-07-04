module OwnedPages
  module Connect
    class Linkedin < ::OwnedPages::Connect::Base
      def call
        return broadcast(:invalid) if @form.invalid? || invalid_account?
        disconnect
        create
        broadcast(:ok)
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
          page = Page::FindOrCreateAndFetch.new(@provider.id, 'handle', nil,
            checked_page['uid']).call
          connect_owned_page(page, nil)
          PageWorker.new.perform(page)
          ::LinkedinPostsWorker.perform_async(page.id)
        end
      end
    end
  end
end
