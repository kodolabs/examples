module Integrations
  module Eventbrite
    class UploadLogo < Rectify::Command
      MEDIA_UPLOAD_URL = 'https://www.eventbriteapi.com/v3/media/upload/'.freeze

      def initialize(user, event)
        @token = user.organiser.eventbrite_token
        @event = event
      end

      def call
        instructions_data = retrieve_instructions(@token)
        return unless instructions_data
        return unless upload_file(@event.logo.file.file, instructions_data)
        image = get_image(@token, instructions_data['upload_token'])
        @event.update_attribute(:eventbrite_logo_id, image['id']) if image
      end

      private

      def retrieve_instructions(token)
        url = MEDIA_UPLOAD_URL + "?type=image-event-logo&token=#{token}"
        response = RestClient.get(url)
        JSON.parse(response)
      rescue
        false
      end

      def upload_file(filename, data)
        upload_url = data['upload_url']
        post_args = data['upload_data']
        RestClient.post(upload_url, 'AWSAccessKeyId': post_args['AWSAccessKeyId'],
                                    key: post_args['key'],
                                    bucket: post_args['bucket'],
                                    acl: post_args['acl'],
                                    policy: post_args['policy'],
                                    signature: post_args['signature'],
                                    file: File.open(filename))
      rescue
        false
      end

      def get_image(token, upload_token)
        url = MEDIA_UPLOAD_URL + "?token=#{token}"
        response = RestClient.post(url, 'upload_token': upload_token)
        JSON.parse(response)
      rescue
        false
      end
    end
  end
end
