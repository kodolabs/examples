module Articles
  class ArchivedProvider
    def initialize(params)
      @params = params
    end

    def call
      @scope ||= Article.includes(:links).where(links: { article_id: nil })
      add_condition_by_title
    end

    private

    def add_condition_by_title
      return @scope if @params[:title].blank?
      @scope = @scope.search_by_title(@params[:title])
    end
  end
end
