module Shares
  module Commands
    class PublishFacebook
      def initialize(owned_page)
        @owned_page = owned_page
      end

      def call(data)
        return publish_video(data) if data.video_url
        response = data.image_urls.present? ? publish_with_image(data) : publish(data)
        uid(response)
      end

      def publish_with_image(data)
        client.put_picture(data.image_urls.first, message: data.message)
      end

      def publish(data)
        data.link.presence ? publish_link(data) : publish_without_link(data)
      end

      def publish_without_link(data)
        options = { message: data.message }
        options[:name] = data.name if data.name
        options[:description] = data.description if data.description
        client.put_connections('me', 'feed', options)
      end

      def publish_link(data)
        options = { link: data.link }
        options[:message] = data.message if data.message
        client.put_connections('me', 'feed', options)
      end

      def publish_video(data)
        res = publish_video_file(data)
        uid(res)
      end

      def publish_video_file(data)
        client.put_video(data.video_url, description: data.message)
      end

      def publish_video_thumbnail(data)
        return nil if data.thumb_url.blank?
        client.put_picture(data.thumb_url, message: data.content)
      end

      def client
        @client ||= ::Facebook::PageService.new(@owned_page).graph
      end

      def uid(response)
        return nil if response.blank?
        response['post_id'] || response['id']
      end
    end
  end
end
