class ArticleSweeper < BaseSweeper
  observe Article

  def after_save(record)
    if record.score_changed?
      expire_cell_state GamesCell, :highest_rated
    end
    expire_home_page_cells
  end

  def after_create(record)
    expire_cell_state ReviewsCell, :latest
    expire_home_page_cells
  end

  def after_destroy(record)
    expire_cell_state ReviewsCell, :latest
    expire_home_page_cells
  end

  def expire_home_page_cells
    expire_cell_state(HomePageCell, :latest_previews)
    expire_cell_state(HomePageCell, :latest_reviews)
  end
end
