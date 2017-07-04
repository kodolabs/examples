module Integrations
  module Eventbrite
    class CheckAuthorize < Rectify::Command
      require 'eventbrite'

      def initialize(user)
        @organiser = user.organiser
        ::Eventbrite.token = @organiser.eventbrite_token
      end

      def call
        return broadcast(:unauthorized_user) unless @organiser.eventbrite_token.present?
        ::Eventbrite::User.retrieve(@organiser.eventbrite_id)
        broadcast(:ok)
      rescue ::Eventbrite::AuthenticationError
        broadcast(:invalid_token)
      end
    end
  end
end
