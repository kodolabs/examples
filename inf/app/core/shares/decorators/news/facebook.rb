module Shares
  module Decorators
    module News
      class Facebook < Shares::Decorators::News::Base
        private

        def image_post(record)
          {
            image_urls: [record.image.path],
            message: message_for(record)
          }
        end
      end
    end
  end
end
