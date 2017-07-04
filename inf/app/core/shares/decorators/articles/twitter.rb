module Shares
  module Decorators
    module Articles
      class Twitter < Shares::Decorators::Articles::Base
        private

        def content(record)
          cut(record.content)
        end

        def link_post(link)
          { message: link }
        end
      end
    end
  end
end
