module Shares
  module Decorators
    module Posts
      class Linkedin < Shares::Decorators::Posts::Base
        private

        def link_post(link, record)
          message = ''
          message += "#{@quote}\n" if @quote.present?
          message += record.content.to_s if record.content.present?
          message += link

          { message: message }
        end

        def post(record)
          record.decorate.media_records.presence ? media_post(record) : text_post(record)
        end

        def media_post(record)
          message = @quote.presence ? "#{@quote}\n" : ''
          message += content_for(record)
          message += record.videos.first.url if record.videos.any?

          image_url = record.videos.first&.thumb_url if record.videos.any?
          image_url ||= record.decorate&.external_image_url

          options = { message: message }
          options[:image_urls] = [image_url] if image_url.present?
          options
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
