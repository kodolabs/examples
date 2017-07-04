module Integrations
  module Eventbrite
    class Webhooks < Rectify::Command
      def host_url
        "http://#{ENV['HOST_NAME']}/webhooks/eventbrite"
      end

      def webhooks
        [
          { url: "#{host_url}/event_updated", actions: 'event.updated' },
          { url: "#{host_url}/order_placed", actions: 'order.placed' }
        ]
      end

      def eventbrite_webhooks
        ::Eventbrite::Webhook.retrieve('')
      rescue StandardError => e
        Rollbar.error(e)
        false
      end
    end
  end
end
