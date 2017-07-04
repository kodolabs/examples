module Webhooks
  module Facebook
    class Create
      def initialize(id)
        @owned_page = OwnedPage.find_by(id: id)
      end

      def call
        graph = Koala::Facebook::API.new(@owned_page.token)
        graph.put_connections(uid, 'subscribed_apps')
      rescue Koala::Facebook::ClientError
        return
      rescue => error
        Rollbar.error(error)
        return
      end

      private

      def uid
        @owned_page.page.uid
      end

      def verify_token
        Digest::SHA1.hexdigest ENV['FACEBOOK_WEBHOOKS_TOKEN']
      end
    end
  end
end
