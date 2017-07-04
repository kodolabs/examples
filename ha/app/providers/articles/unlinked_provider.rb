module Articles
  class UnlinkedProvider
    def initialize(params)
      @params = params
    end

    def call
      @scope ||= Article.includes(relations).has_links.where(links: { campaign_id: nil })
      add_condition_by_title
      add_condition_by_domain
      add_condition_by_topics
    end

    private

    def relations
      [:links, :topics, { blog: [host: :domain] }]
    end

    def add_condition_by_title
      return @scope if @params[:title].blank?
      @scope = @scope.search_by_title(@params[:title])
    end

    def add_condition_by_domain
      return @scope if @params[:domain].blank?
      @scope = @scope.search_by_domain(@params[:domain])
    end

    def add_condition_by_topics
      return @scope if @params[:topics].blank?
      @scope = @scope.search_by_topics(@params[:topics]&.split(','))
    end
  end
end
