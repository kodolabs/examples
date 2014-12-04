class UserReviewDecorator < ArticleDecorator
  include ScoreHelper

  def review_score
    round(object.user_score.score)
  end

  def mark
    score_mark(object.user_score.score)
  end

  def reviews_info
    h.human_date(object.created_at)
  end

  def author
    object.user.login
  end

  def author_avatar
    object.user.avatar
  end

  def related_game_link
    h.link_to object.game.name, h.admin_game_path(object.game) unless object.game.nil?
  end

  def published
    "#{h.human_date object.created_at} | By #{object.user.name}".html_safe
  end
end
