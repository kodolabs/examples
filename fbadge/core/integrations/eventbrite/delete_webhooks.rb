module Integrations
  module Eventbrite
    class DeleteWebhooks < Integrations::Eventbrite::Webhooks
      def initialize(organiser)
        @organiser = organiser
        ::Eventbrite.token = @organiser.eventbrite_token
        @webhook_list = eventbrite_webhooks
      end

      def call
        return unless @webhook_list
        webhooks.each do |webhook|
          @webhook_list.webhooks.each do |hook|
            next unless webhook[:url] == hook.endpoint_url
            delete_webhook(hook.id)
          end
        end
      end

      private

      def delete_webhook(webhook_id)
        ::Eventbrite::Webhook.delete(webhook_id)
      rescue StandardError => e
        Rollbar.error(e)
      end
    end
  end
end
