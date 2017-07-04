module NewsItems
  class Create < ::NewsItems::Base
    def call
      @form.cache_image
      return broadcast(:invalid, @form) if @form.invalid?
      @news = News.new(@form.model_attributes)
      domain_for(@news)
      return broadcast(:invalid, @form) unless @news.save
      broadcast(:ok, @news)
    end
  end
end
