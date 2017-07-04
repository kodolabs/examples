module Integrations
  module Eventbrite
    class CreateWebhooks < Integrations::Eventbrite::Webhooks
      def initialize(user)
        @user = user
        ::Eventbrite.token = @user.organiser.eventbrite_token
        @webhook_list = eventbrite_webhooks
      end

      def call
        webhooks.each do |webhook|
          webhook_present = check_webhook_presence(webhook) if @webhook_list
          create_webhook(webhook[:url], webhook[:actions]) unless webhook_present
        end
      end

      private

      def check_webhook_presence(webhook)
        webhook_present = false
        @webhook_list.webhooks.each do |hook|
          webhook_present = true if webhook[:url] == hook.endpoint_url
        end
        webhook_present
      end

      def create_webhook(url, actions)
        ::Eventbrite::Webhook.create(endpoint_url: url, actions: actions)
      rescue
        false
      end
    end
  end
end
