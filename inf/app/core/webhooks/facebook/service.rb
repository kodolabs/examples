module Webhooks
  module Facebook
    class Service
      def initialize
        @secret = ENV['FACEBOOK_APP_SECRET']
      end

      # Don't use Koala::Facebook::RealtimeUpdates#validate_update
      # because it makes uneccesary oauth auth on initialization for this method

      def valid_integrity?(body, headers)
        request_signature = headers['X-Hub-Signature']
        signature_parts = request_signature.split('sha1=')
        request_signature = signature_parts[1]
        calculated_signature = OpenSSL::HMAC.hexdigest('sha1', @secret, body)
        calculated_signature == request_signature
      end
    end
  end
end
