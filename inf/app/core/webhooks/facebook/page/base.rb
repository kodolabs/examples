module Webhooks
  module Facebook
    module Page
      class Base
        def initialize(entries)
          @entries = entries
        end

        def call
          @entries.each do |entry|
            entry['changes'].each do |change|
              case change['field']
              when 'picture', 'general_info', 'title', 'description'
                Webhooks::Facebook::Page::Info.new(entry['id']).call
              when 'feed'
                Webhooks::Facebook::Page::Feed.new(change['value']).call
              end
            end
          end
        end
      end
    end
  end
end
