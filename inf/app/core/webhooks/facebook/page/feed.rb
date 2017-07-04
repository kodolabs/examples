module Webhooks
  module Facebook
    module Page
      class Feed
        def initialize(value)
          @value = value
        end

        def call
          return unless %w(post video).include?(@value['item'])

          case @value['verb']
          when 'remove'
            remove
          when 'add'
            add
          end
        end

        private

        def remove
          id = Post.facebook.find_by(uid: @value['post_id']).try(:id)
          DestroyPostWorker.perform_async(id) if id
        end

        def add
          update_posts
          update_publication
        end

        def update_posts
          page = ::Page.find_by(uid: @value['sender_id'])
          return if page.blank?
          ::RecentPostsWorker.new.perform(page.id)
        end

        def update_publication
          post = ::Post.facebook.find_by(uid: @value['post_id'])
          publication = ::Publication.find_by(uid: @value['post_id'])
          uid = @value['post_id']
          ::UpdatePublication.new(publication, post, uid).call
        end
      end
    end
  end
end
