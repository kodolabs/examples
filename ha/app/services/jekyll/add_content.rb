class Jekyll::AddContent < Jekyll::Base
  def call
    update_last_error
    context.blog.articles.need_publish.each do |article|
      content = prepare_content(article)
      generate_post_file(article, content)
    end
  rescue => e
    update_last_error("Generate content: #{e.message}")
    context.fail!
  end

  private

  def prepare_content(article)
    return article.body if article.article_images.blank?
    load_article_images(article)
  end

  def load_article_images(article)
    return article.body if article.article_images.blank?

    content = article.body
    article.article_images.each do |img|
      image_full_path = image_path(img)
      create_images_folder(image_full_path)
      File.open(image_full_path, 'wb') do |fo|
        fo.write open(img.file.url).read rescue ''
      end
      content.gsub!(img.file.url, image_full_path.gsub(images_path, ''))
    end
    content
  end

  def generate_post_file(article, content)
    File.open(article_file_path(article), 'w') do |f|
      f.puts '---'
      f.puts 'layout: post'
      f.puts "title: '#{article.title}'"
      f.puts "author: '#{article.blog.host.author}'" if article.blog&.host&.author&.present?
      f.puts "date: #{article.published_at}"
      f.puts "categories: '#{article.categories.join(',')}'" if article.categories.present?
      f.puts '---'
      f.puts content
    end
  end

  def generate_filename(article)
    "#{[article.published_at.to_date, article_slug(article)].join('-')}.markdown"
  end

  def article_file_path(article)
    [posts_path, generate_filename(article)].join('/')
  end

  def image_path(image)
    path = URI.parse(image.original_path).path rescue nil if image.original_path.present?
    return "#{images_path}#{path}" if path.present?
    "#{images_path}/images/#{image.created_at.strftime('%Y/%m')}/#{image.file.filename}"
  end

  def create_images_folder(path)
    path_to_folder = path.rpartition('/').first
    FileUtils.mkdir_p(path_to_folder)
  end
end
