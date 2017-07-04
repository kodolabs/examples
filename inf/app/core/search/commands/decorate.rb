module Search
  module Commands
    class Decorate
      def initialize(response, options = {})
        @response = response
        @posts = response[:posts]
        @news = response[:news]
        @customer = options[:customer]
      end

      def call
        find_posts_in_db
        decorate_news
        decorate_posts
        decorate

        @response[:posts] = @posts
        @response[:news] = @news
        @response
      end

      private

      def decorate
        decorate_items @posts
        decorate_items @news
      end

      def decorate_news
        @news = @news.map do |news_item|
          record = news_item.decorate
          OpenStruct.new(
            record: record,
            share_data: {
              id: record.id,
              type: 'news',
              auto_share_id: record.auto_share_id,
              share_id: record&.share&.id,
              remove: 1
            }
          )
        end
      end

      def decorate_items(records)
        records.map! do |post|
          next if post&.record&.resolved?(@customer)
          post.share = find_share(post.record)
          post.auto_disabled = auto_disabled?(post.share)
          post.share_class = share_class(post.record)
          post.auto_class = auto_class(post.record)
          post.share_icon = share_icon(post)
          post.share_color_class = share_color_class(post.share)
          post.auto_active = auto_active(post.share)
          post
        end.compact!
      end

      def decorate_posts
        @posts.map do |post|
          record = find_record(post)
          post.record = record
          post.followed = followed?(post.author_handle)
          post.text = text_for(post)
          post.share_data = {
            uid: post.uid,
            author_name: post.author_name,
            author_handle: post.author_handle,
            provider: provider,
            id: post.record&.id,
            type: 'posts',
            auto_share_id: post.record&.auto_share_id,
            share_id: post.record&.share&.id,
            remove: 1
          }
        end
      end

      def followed?(handle)
        followed_pages.where(handle: handle).present?
      end

      def followed_pages
        @followed_pages ||= @customer.primary_feed.pages.where(provider_id: provider)
      end

      def auto_disabled?(share)
        share.presence && !share.auto?
      end

      def find_posts_in_db
        @db_posts ||= Post.twitter.where(uid: uids).includes(:shares)
      end

      def find_share(record)
        return nil if record.blank?
        record.shares.connected.find_by(customer: @customer).try(:decorate)
      end

      def find_record(item)
        @db_posts.find_by(uid: item.uid).try(:decorate)
      end

      def uids
        @posts.map(&:uid)
      end

      def share_class(record)
        return nil if record.blank?
        record.share_button_class
      end

      def auto_active(share)
        return nil if share.blank?
        share.auto ? true : nil
      end

      def share_color_class(share)
        return nil if share.blank?
        share.auto ? 'ui-soc-icon--green' : nil
      end

      def auto_class(record)
        return nil if record.blank?
        record.auto_share_button_class
      end

      def share_icon(post)
        return nil if post.record.blank? || post.share.blank?
        post.record.icon_class
      end

      def provider
        @provider ||= Provider.twitter.id
      end

      def text_for(post)
        post.text.presence ? ::PostDecorator.new(nil).highlight(post.text) : post.text
      end
    end
  end
end
