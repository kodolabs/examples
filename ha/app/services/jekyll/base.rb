class Jekyll::Base
  include Interactor
  attr_accessor :host, :blog

  def initialize(context = {})
    @host = context[:host]
    @blog = context[:blog]
    super
  end

  private

  def clear_site_folder
    FileUtils.rm_rf(site_path)
  end

  def site_path
    folder_name = if context.blog.present?
      "blog-#{context.blog.id}"
    else
      "host-#{context.host.id}-blog"
    end
    "#{ENV['BLOGS_DIR_PATH']}/#{folder_name}"
  end

  def destination_path
    [site_path, '_site'].join('/')
  end

  def settings_path
    [site_path, '_config.yml'].join('/')
  end

  def posts_path
    [site_path, '_posts'].join('/')
  end

  def images_path
    [site_path, 'assets/images'].join('/')
  end

  def destination_images_path
    [destination_path, 'assets/images'].join('/')
  end

  def update_last_error(message = nil)
    @host.update(last_error: message)
  end

  def permalink_template
    '/:year/:month/:day/:title.html'
  end

  def article_slug(article)
    article.slug.present? ? article.slug : generate_slug(article.title)
  end

  def generate_slug(string)
    string.mb_chars.to_s.downcase.gsub(/\s/, '-')
  end
end
