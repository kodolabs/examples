module Search
  module Commands
    class Twitter
      LIMIT = 10

      def initialize(query, options = {})
        @query = query
        @result_type = options[:result_type]
        @max_id = options[:max_id].presence ? options[:max_id].to_i : nil
        @type = options[:type]
      end

      def call
        return blank if @query.blank? || no_twitter_query?

        @service = ::Twitter::Service.new
        res = @service.search(@query, options)

        {
          posts: posts(res),
          max_id: max_id(res)
        }
      end

      private

      def max_id(res)
        next_results = res.attrs[:search_metadata][:next_results]
        return nil if next_results.blank?
        CGI.parse(next_results.split('?').last)['max_id'].first
      end

      def posts(res)
        posts = res.take(LIMIT)

        posts.map do |post|
          media = media_for(post)
          OpenStruct.new(
            text: post.attrs[:full_text],
            author_name: post.user.name,
            author_handle: post.user.screen_name,
            author_avatar: post.user.profile_image_url.to_s,
            date: post.created_at,
            likes: post.favorite_count,
            shares: post.retweet_count,
            uid: post.id,
            images: images_for(media)
          )
        end
      end

      attr_reader :result_type

      def options
        opts = {
          result_type: result_type,
          count: LIMIT,
          include_entities: true,
          tweet_mode: 'extended',
          exclude: 'retweets'
        }

        opts[:max_id] = @max_id - 1 if @max_id
        opts
      end

      def images_for(media)
        images = media.select { |m| media?(m) }
        images.map { |image| formed_link(image.media_url) }
      end

      def formed_link(uri)
        uri.origin + uri.request_uri
      end

      def media_for(post)
        post.media.presence ? post.media : post.retweeted_status&.media
      end

      def media?(media)
        media_types = %w(Photo AnimatedGif Video)
        return true if media_types.include?(media_type(media))
        media.find { |m| media_types.include?(media_type(m)) }
      end

      def media_type(media)
        media.class.name.try(:split, '::').try(:last)
      end

      def no_twitter_query?
        @type.presence && @type != 'trends'
      end

      def blank
        { posts: [], max_id: nil }
      end
    end
  end
end
