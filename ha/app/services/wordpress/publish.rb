class Wordpress::Publish
  include Interactor

  def call
    if context.article.external_id.present?
      Wordpress::UpdatePost.new(context.article).call
    else
      Wordpress::CreatePost.new(context.article).call
    end
  end
end
