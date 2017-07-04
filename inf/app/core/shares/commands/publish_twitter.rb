module Shares
  module Commands
    class PublishTwitter
      def initialize(owned_page)
        @owned_page = owned_page
      end

      def call(data)
        return if @owned_page.account.blank?
        return retweet(data) if data.uid.present?
        if data.image_urls || data.image_remote_urls
          update_with_media(data).id
        else
          client.update(data.message).id
        end
      end

      private

      def update_with_media(data)
        media = media_for(data)
        client.update_with_media(data.message, media)
      rescue
        message = data.message
        message += "\n#{data.link}" if data.link
        client.update(message)
      end

      def media_for(data)
        return data.image_urls if data.image_urls

        data.image_remote_urls.map { |url| download_media(url) }
      end

      def client
        @client ||= ::Twitter::Service.new(@owned_page.account).client
      end

      def download_media(url)
        file = open(url)
        file_name = SecureRandom.hex(10)

        temp_file = Tempfile.new([file_name, '.mp4'])
        temp_file.binmode
        temp_file.write(file.read)
        temp_file.close

        open(temp_file.path)
      end

      def retweet(data)
        client.retweet(data.uid).first.id
      end
    end
  end
end
