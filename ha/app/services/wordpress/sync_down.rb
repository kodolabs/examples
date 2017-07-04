class Wordpress::SyncDown
  attr_accessor :blog, :wrapper

  def initialize(blog)
    @blog = blog
    @authors = {}
    @categories = {}
  end

  def call
    return if blog.blank? || !blog&.host&.wordpress?
    update_last_error

    sync_blog_settings
    sync_posts
  rescue => e
    update_last_error("Blog sync down: #{e.message}")
  end

  private

  def sync_blog_settings
    info = wrapper.info
    return if info.blank?

    blog.host.update!(
      blog_title: info.name,
      description: info.description
    )
  end

  def sync_posts
    page = 1
    loop do
      posts = find_posts(page)
      break if posts.blank?

      posts.each do |post|
        service = Articles::AutoSave.call(blog: blog, post: prepare_post(post))
        raise service&.message if service.failure?
      end
      page += 1
    end
  end

  def wrapper
    @wrapper ||= WP::API::Client.new(host: blog.domain)
  end

  def prepare_post(post)
    post = post.attributes
    post['author'] = find_author(post['author'])
    post['categories'] = post_categories(post)

    OpenStruct.new(
      id: post['id'],
      url: post['link'],
      title: post['title'].try(:[], 'rendered'),
      body: post['content'].try(:[], 'rendered'),
      published_at: post['date'],
      author: post['author'].try(:[], 'name'),
      slug: post['slug'],
      categories: post['categories']&.map do |category|
                    category.try(:[], 'name')
                  end.compact
    )
  end

  def find_author(id)
    return @authors[id] if @authors[id].present?
    @authors[id] = wrapper.user(id).attributes
  rescue
    nil
  end

  def post_categories(post)
    post_categories = post['categories'].map do |category_id|
      next if @categories[category_id].blank?
      @categories[category_id]
    end.compact

    return post_categories if post['categories'].size == post_categories.size

    post_categories = wrapper.categories(post: post['id'], should_raise_on_empty: false).map(&:attributes)
    post_categories.map do |category|
      @categories[category['id']] = category
    end
  rescue
    []
  end

  def find_posts(page)
    wrapper.posts(page: page, should_raise_on_empty: false)
  end

  def update_last_error(message = nil)
    blog.host.update(last_error: message)
  end
end
