module Shares
  module Decorators
    module Posts
      class Twitter < Shares::Decorators::Posts::Base
        private

        def link_post(link, record)
          text = ''
          text += "#{@quote}\n" if @quote.present?
          text += record.content.to_s if record.content.present?
          message = text.presence ? cut(text, link) : link
          { message: message }
        end

        def post(record)
          return video_post(record) if record.videos.any?
          record.images.presence ? image_post(record) : text_post(record)
        end

        def video_post(record)
          image_urls = record.videos.pluck(:url)
          media_post(image_urls, record)
        end

        def image_post(record)
          image_urls = record.images.pluck(:url)
          media_post(image_urls, record)
        end

        def text_post(record)
          message = @quote.presence ? cut(quote, record.content) : record.content
          { message: message }
        end

        def media_post(urls, record)
          {
            image_remote_urls: urls,
            message: title_for(record)
          }
        end

        def title_for(record)
          if @quote.present?
            length = max_content_size - record.link.length - 3
            "#{@quote.truncate(length)}\n\n#{record.link}"
          else
            link = record.link
            url_length = link.length
            text_length = max_content_size - url_length + 1
            content = content_for(record)
            "#{content.truncate(text_length)} #{link}"
          end
        end
      end
    end
  end
end
