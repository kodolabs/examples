module Shares
  module Decorators
    module Posts
      class Base < ::Shares::Decorators::Base
        def decorate(record)
          return retweet_post(record) if twitter?(record)
          link = link_for(record)
          opengraph?(link) ? link_post(link, record) : post(record)
        end

        private

        def link_for(record)
          @link ||= record.twitter? ? record.decorate.original_content_link : record.link
        end

        def retweet_post(record)
          if @quote.present?
            { message: cut(@quote, record.link) }
          else
            { uid: record.uid }
          end
        end

        def target
          self.class.to_s.demodulize.downcase
        end

        def twitter?(record)
          record.twitter? && target == 'twitter'
        end

        def content_for(record)
          record.content || record.attrs.try(:[], 'text') ||
            record.description || record.title
        end
      end
    end
  end
end
