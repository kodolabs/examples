module Shares
  module Decorators
    module News
      class Linkedin < Shares::Decorators::News::Base
        private

        def image_post(record)
          {
            image_urls: [record.decorate.external_image_url],
            message: message_for(record)
          }
        end
      end
    end
  end
end
