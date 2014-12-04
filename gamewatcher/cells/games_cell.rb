class GamesCell < BaseCell
  include ScoreHelper

  cache :highest_rated, expires_in: 1.hour do |args|
    args[:company].id unless args.nil?
  end

  cache :game_info do |args|
    args[:game].id unless args.nil?
  end

  cache :game_header, expires_in: 15.minutes do |args|
    args[:game].id unless args.nil?
  end

  cache :upcoming_games, expires_in: 1.hour do |args|
    [args[:genre], args[:tag]] unless args.nil?
  end

  cache :related_games, expires_in: 24.hour do |args|
    args[:game] unless args.nil?
  end

  def new_releases
    @new_releases = Game.last(3)
    render
  end

  def highest_rated(args={})
    company = args[:company]

    @highest_rated = if company
      GameDecorator.decorate_collection company.games.released_in_last_year.top_rated.limit(5)
    else
      GameDecorator.decorate_collection Game.released_in_last_year.top_rated.limit(5)
    end

    render if @highest_rated.any?
  end

  def related_games(args={})
    @game = args[:game]
    @related_games = @game.similar(3)
    render
  end

  def game_info(args={})
    @game = args[:game]
    render
  end

  def reviews(args={})
    reviews = args[:reviews]
    @reviews = ReviewDecorator.decorate_collection reviews.sorted.preload(:game, :admin)

    render
  end

  def summary_review(args={})
    @game = args[:game]
    @review = ReviewDecorator.decorate @game.reviews.published.sorted.first
    render unless @review.blank?
  end

  def user_score(args={})
    @game = args[:game]
    @user = args[:user]
    @score = @game.score_by_user(@user)
    @user_id = @user.nil? ? 'null' : @user.id
    @user_score = UserScoreDecorator.decorate(UserScore.where(game: @game, user: @user).first_or_initialize)
    @button_text = @user_score.user_review ? 'Edit review' : 'Add review'
    render if @game.released?
  end

  def user_review(args={})
    @game = args[:game]
    @user = args[:user]
    @user_score =  UserScoreDecorator.decorate(args[:user_score] || UserScore.where(game: @game, user: @user).first_or_initialize)
    @user_score.build_user_review(game: @game, user: @user) unless @user_score.user_review
    render
  end

  def upcoming_games(args={})
    @games = GameDecorator.decorate_collection Game.by_genre(args[:genre]).by_tag(args[:tag]).upcoming
    render if @games.any?
  end

  def game_header(args={})
    @game = args[:game]

    render
  end

  def game_tabs(args={})
    @game = args[:game]

    render
  end
end
