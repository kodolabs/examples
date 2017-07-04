module Shares
  module Decorators
    module Articles
      class Base < ::Shares::Decorators::Base
        def decorate(record)
          link = link_for(record)
          opengraph?(link) ? link_post(link) : post(record)
        end

        private

        def link_for(record)
          message = record.content.strip
          url = url_for(message)
          url.presence ? url : nil
        end

        def post(record)
          {
            image_urls: image_urls_for(record),
            message: content(record)
          }
        end

        def image_urls_for(record)
          record.images.map { |image| image.file.path }
        end

        def url_for(message)
          message.scan(/(#{URI.regexp})/).try(:first).try(:first)
        end
      end
    end
  end
end
