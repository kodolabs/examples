class Jekyll::Finish < Jekyll::Base
  def call
    clear_site_folder
    update_articles
    update_blog
  rescue => e
    update_last_error("Finish: #{e.message}")
    context.fail!
  end

  private

  def update_articles
    synced_at = Time.zone.now
    context.blog.articles.need_publish.each do |article|
      article.update!(
        url: generate_url(article),
        synced_at: synced_at,
        publishing_status: :publish,
        status: :published
      )
    end
  end

  def update_blog
    context.blog.update(synced_at: Time.zone.now)
  end

  def generate_url(article)
    path = Jekyll::URL.new(
      template: permalink_template,
      placeholders: {
        categories: article.categories&.first,
        year: article.published_at.strftime('%Y'),
        month: article.published_at.strftime('%m'),
        day: article.published_at.strftime('%d'),
        title: article_slug(article)
      }
    ).to_s
    URI::HTTP.build(host: context.blog.domain, path: path).to_s
  end
end
