module NewsItems
  class Filter
    def initialize(item)
      @item = item
    end

    def call
      @keywords = BannedKeyword.pluck(:keyword)

      klass = @item.class.name
      case klass
      when 'RssItem', 'RssItemDecorator'
        filter_rss
      when 'News', 'NewsItems::NewsForm'
        filter_news
      end
    end

    private

    def filter_rss
      content = @item.title.to_s + @item.text.to_s + @item.url.to_s

      filtered?(content)
    end

    def filter_news
      content = @item.title.to_s + @item.description.to_s + @item.url.to_s
      filtered?(content)
    end

    def filtered?(content)
      @keywords.any? { |keyword| content.include?(keyword) }
    end
  end
end
