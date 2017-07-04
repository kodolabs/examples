module Integrations
  module Eventbrite
    class Deauthorize < Rectify::Command
      def initialize(user)
        @organiser = user.organiser
      end

      def call
        delete_webhooks
        return broadcast(:ok) if @organiser.update_attributes(eventbrite_token: nil)
        broadcast(:invalid)
      end

      private

      def delete_webhooks
        Integrations::Eventbrite::DeleteWebhooks.call(@organiser)
      end
    end
  end
end
