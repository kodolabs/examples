module NewsItems
  class Update < ::NewsItems::Base
    def call
      @form.cache_image
      return broadcast(:invalid) if @form.invalid?
      news = find_news(@form)
      return broadcast(:invalid) unless news
      return broadcast(:invalid) unless update_news(news, @form)
      domain_for(news)
      news.save if news.changed?
      broadcast(:ok)
    end

    private

    def find_news(form)
      News.find(form.id)
    end

    def update_news(news, form)
      news.update_attributes(form.model_attributes)
    end
  end
end
