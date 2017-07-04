module Shares
  module Decorators
    module News
      class Base < ::Shares::Decorators::Base
        def decorate(record)
          opengraph?(record.url) ? link_post(record) : post(record)
        end

        def link_post(record)
          options = { link: record.url }
          options[:message] = @quote if @quote.present?
          options
        end

        def post(record)
          record.image.presence ? image_post(record) : text_post(record)
        end

        def message_for(record)
          message = @quote.presence ? quote : ''
          message += "#{record.title}\n#{record.url}"
          message += "\n#{record.description}" if record.description.present?
          message
        end

        def text_post(record)
          { message: message_for(record) }
        end
      end
    end
  end
end
