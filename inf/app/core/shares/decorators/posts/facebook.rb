module Shares
  module Decorators
    module Posts
      class Facebook < Shares::Decorators::Posts::Base
        private

        def link_post(link, record)
          options = { link: link }

          message = ''
          message += "#{@quote}\n" if @quote.present?
          message += record.content.to_s if record.content.present?

          options[:message] = message if message.present?
          options
        end

        def post(record)
          return video_post(record) if record.videos.any?
          record.images.presence ? image_post(record) : text_post(record)
        end

        def video_post(record)
          message = @quote.presence ? "#{@quote}\n" : ''
          message += content_for(record)

          {
            video_url: record.videos.first&.url,
            message: message,
            thumb_url: record.images.first&.url,
            link: record.link
          }
        end

        def image_post(record)
          message = @quote.presence ? "#{@quote}\n" : ''
          message += content_for(record)
          {
            image_urls: [record.images.first.url],
            message: message
          }
        end

        def text_post(record)
          message = @quote.presence ? "#{@quote}\n" : ''
          message += content_for(record)

          { message: message }
        end
      end
    end
  end
end
