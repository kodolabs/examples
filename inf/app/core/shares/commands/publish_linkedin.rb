module Shares
  module Commands
    class PublishLinkedin
      def initialize(owned_page)
        @owned_page = owned_page
        page = @owned_page.page
        @uid = page.uid
        @api = ::Linkedin::Posts.new(@owned_page.account.token)
      end

      def call(data)
        response = data.image_urls.present? ? publish_with_image(data) : publish(data)
        uid(response)
      end

      private

      def publish(data)
        data.link.presence ? publish_link(data) : publish_without_link(data)
      end

      def publish_without_link(data)
        text = data.message
        create(text: text)
      end

      def publish_link(data)
        text = data.link
        create(text: text)
      end

      def publish_with_image(data)
        image_url = data.image_urls.first
        text = data.message || ''
        create(text: text, image_url: image_url)
      end

      def uid(response)
        response['updateKey']
      end

      def create(options)
        @api.create(@uid, options)
      end
    end
  end
end
