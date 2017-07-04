module Integrations
  module Eventbrite
    class Authorize < Rectify::Command
      def initialize(user, auth_data)
        @user = user
        @auth_data = auth_data
      end

      def call
        return broadcast(:invalid) if credentials.blank?
        return broadcast(:invalid) if credentials_expired?
        if @user.organiser.update_attributes(eventbrite_token: token, eventbrite_id: organiser_id)
          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end

      private

      def credentials
        @auth_data[:credentials]
      end

      def credentials_expired?
        @auth_data[:credentials][:expires]
      end

      def token
        @auth_data[:credentials][:token]
      end

      def organiser_id
        @auth_data[:extra][:raw_info][:id]
      end
    end
  end
end
