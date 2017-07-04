class Wordpress::ApiBase
  attr_accessor :article, :host, :wrapper

  def initialize(article)
    @article = article
    @host = @article.blog&.host
  end

  private

  def init_wrapper
    @wrapper ||= WP::API::Client.new(host: host.domain.name)
    @wrapper.basic_auth(username: host.wp_login, password: host.wp_password)
  end

  def post_categories
    return {} if article.categories.blank?
    wp_categories = {}
    wrapper.categories.each do |c|
      wp_categories[c.name.downcase] = c.id
    end
    categories = article.categories.map do |category|
      if wp_categories.keys.include?(category.downcase)
        wp_categories[category.downcase]
      else
        wrapper.create_category(name: category)&.id
      end
    end.compact
    { categories: categories }
  end

  def article_content
    content = article.body.clone
    article.article_images.each do |image|
      content.gsub!(image.file_url, image.original_path)
    end
    content
  end

  def access_to_wp?
    [:wp_login, :wp_password].all? do |attr|
      host[attr].present?
    end
  end

  def update_last_error(message = nil)
    @article&.update(last_error: message)
    @host&.update(last_error: message)
  end
end
