class Facebook::SavePosts
  attr_reader :posts_count
  def initialize(page, options = {})
    @page = page
    @limit = options[:limit]
  end

  def call
    return if @page.blank?
    @page.touch(:last_crawled_at)
    @posts_count = 0

    facebook = Facebook::Service.new
    result = facebook.fetch_posts(@page.api_handle, post_attributes)
    while result.present? && limit_not_reached?
      posts = prepare_post_attributes(result)
      create_posts(posts, @page)
      result = next_page(result)
    end
  end

  private

  def post_attributes
    {
      since: 1.month.ago.to_i,
      fields: [
        'id',
        'name',
        'message',
        'full_picture',
        'created_time',
        'likes.limit(0).summary(1)',
        'comments.limit(0).summary(1)',
        'shares',
        'from',
        'link',
        'source',
        'story',
        'description',
        'caption'
      ]
    }
  end

  def prepare_post_attributes(result)
    result.map do |post|
      {
        uid: post['id'],
        title: post['name'],
        content: post['message'],
        picture: post['full_picture'],
        posted_at: DateTime.parse(post['created_time']).in_time_zone,
        likes_count: post.try(:[], 'likes').try(:[], 'summary').try(:[], 'total_count'),
        shares_count: post['shares'].try(:[], 'count').to_i,
        author: post['from'].try(:[], 'name'),
        story: post['story'],
        link: post['link'],
        video: post['source'],
        comments_count: post.try(:[], 'comments').try(:[], 'summary').try(:[], 'total_count'),
        description: post['description'],
        caption: post['caption']
      }
    end
  end

  def create_posts(posts, page)
    posts.each do |result|
      attributes = result
      record = page.posts.includes(:images, :videos).find_by(uid: result[:uid])
      post = record ? update_post(record, attributes) : create_post(attributes, page)
      @posts_count += 1 if post&.persisted?
      break unless limit_not_reached?
    end
  end

  def create_post(attributes, page)
    attrs = attributes.except(:picture, :video)
    post = page.posts.create(attrs)

    save_media(post, attributes)

    post
  rescue ActiveRecord::RecordNotUnique
    post
  end

  def update_post(record, attributes)
    record.touch(:updated_at)
    attrs = attributes.except(:picture, :video)
    record.update_attributes(attrs)
    save_media(record, attributes)
    record
  end

  def next_page(result)
    result.next_page
  rescue
    nil
  end

  def save_media(post, attributes)
    return unless post.persisted?

    save_image(post, attributes[:picture])
    save_video(post, attributes[:video], attributes[:picture])
  end

  def save_image(post, image_url)
    existing_image = post.images.first

    return post.images.create(url: image_url) if existing_image.blank?
    return existing_image.destroy if image_url.blank?

    return existing_image.update(url: image_url) if existing_image.url != image_url
  end

  def save_video(post, video_url, image_url)
    existing_video = post.videos.first

    return post.videos.create(url: video_url, thumb_url: image_url) if existing_video.blank?
    return existing_video.destroy if video_url.blank? || image_url.blank?

    existing_video.url = video_url
    existing_video.thumb_url = image_url
    existing_video.save if existing_video.changed?
  end

  def limit_not_reached?
    return true if @limit.blank?

    @posts_count < @limit
  end
end
