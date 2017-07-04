class Migrations::UpdateArticles
  include Interactor

  def call
    unpublish_blog_articles
  rescue => e
    context.fail!(message: e.message)
  end

  private

  def unpublish_blog_articles
    context.blog.articles.update_all(
      url: nil,
      synced_at: nil,
      external_id: nil
    )

    context.blog.articles.article_publish.update_all(
      publishing_status: :pending
    )
  end
end
