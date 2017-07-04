module Shares
  module Decorators
    module Articles
      class Linkedin < Shares::Decorators::Articles::Base
        private

        def content(record)
          record.content
        end

        def link_post(link)
          { link: link }
        end

        def image_urls_for(record)
          [record.decorate.external_image_url]
        end
      end
    end
  end
end
