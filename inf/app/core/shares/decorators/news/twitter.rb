module Shares
  module Decorators
    module News
      class Twitter < Shares::Decorators::News::Base
        private

        def link_post(record)
          message = @quote.presence ? cut(@quote, record.url) : record.url
          { message: message }
        end

        def post(record)
          options = { message: message_for(record) }
          options[:image_urls] = [record.image.path] if record.image.present?
          options
        end

        def message_for(record)
          @quote.presence ? cut(@quote, record.url) : "#{record.title}\n#{record.url}"
        end
      end
    end
  end
end
