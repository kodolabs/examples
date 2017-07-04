module Shares
  module Decorators
    module Articles
      class Facebook < Shares::Decorators::Articles::Base
        private

        def content(record)
          record.content
        end

        def link_post(link)
          { link: link }
        end
      end
    end
  end
end
