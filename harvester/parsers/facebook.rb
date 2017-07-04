module Parsers::Facebook

  RATING_REGEXP = /public ratings/i.freeze
  REVIEWS_REGEXP = /^\d+ reviews/i.freeze

  def show_reviews(doc)
    reviews_link(doc).try(:trigger, 'click')
  end

  def check_log_in_popup(doc)
    doc.first('#expanding_cta_close_button')&.trigger('click')
  end

  def reviews_link(doc)
    doc&.first('a[href*="/reviews"]', text: /Reviews/i)
  end

  def most_recent_link(doc)
    doc.first("div[role='main'] a", text: /MOST RECENT/i)
  end

  def sort_by_recent(doc)
    most_recent_link(doc)&.trigger('click')
  end

  def parse_total_articles_count(doc)
    container = doc.first('#page_reviews_pill_and_histogram')
    @total_articles_count = if container.first("meta[itemprop='ratingCount']", visible: :all)
                              container.first("meta[itemprop='ratingCount']", visible: :all).try(:[], 'content')&.strip&.to_i
                            else
                              container.first('div', text: REVIEWS_REGEXP)&.text&.strip&.match(/(\d+)/).try(:[], 0)&.to_i
                            end
    # @total_articles_count = doc.first("#page_reviews_pill_and_histogram meta[itemprop='ratingCount']", visible: :false).try(:[], 'content')&.strip&.to_i
    log "total_articles_count: #{@total_articles_count}"
  end

  def parse_total_articles_count_with_section(doc)
    if doc.first('span', text: RATING_REGEXP)
      @total_articles_count = doc.first('span', text: RATING_REGEXP)&.first('span', text: RATING_REGEXP)&.text&.strip&.match(/(\d+)/).try(:[], 0)&.to_i
    else
      @total_articles_count = doc.find('[itemprop="aggregateRating"]')&.find('[itemprop="ratingCount"]', visible: :all).try(:[], 'content')&.to_i
    end
    log "total_articles_count: #{@total_articles_count}"
  end

  def visible_articles_count(doc)
    doc.evaluate_script "document.querySelectorAll('#most_recent_list .userContentWrapper').length"
  end

  def scroll(doc)
    log "Scroll, Found reviews count: #{visible_articles_count(doc)}"

    scroll_height = doc.evaluate_script "document.getElementById('most_recent_list').clientHeight"
    doc.driver.scroll_to(0, scroll_height)
  end

  def popup(doc)
    doc.first('._4-u2').first('a', :text => 'Not Now', visible: true)
  end

  def hide_popup(doc)
    log 'Hide popup'
    popup(doc).click()
  end

  def articles(doc)
    articles_container(doc).all('.fbUserContent')
  end

  def articles_for_section(doc)
    doc.first('div[id*="PagesVertexReviewPageletController"]')&.all('#page_recommendations_browse_container li.uiUnifiedStory') ||
    doc.first('div[id*="VertexRecommendationsSection"]')&.all('#page_recommendations_browse_list li.uiUnifiedStory')
  end

  def parse_articles_for_section(doc)
    @found_articles = articles_for_section(doc)
    log "found articles count: #{@found_articles.count}"
    @found_articles.each { |article| parse_article_for_section(article) }
  end

  def articles_container(doc)
    doc.first('#most_recent_list')
  end

  def parse_articles(doc)
    @found_articles = articles(doc)
    log "found articles count: #{@found_articles.count}"
    @found_articles.each { |article| parse_article(article) }
  end

  def parse_article_for_section(article)
    # When user quote other user review, markup of quote looks the same but without link to profile
    return if article.first('strong').blank?

    author = article.first('strong').text.strip
    if article.first('.fbPagesTipsRating')&.first('div[style*="clip"]')
      container = article.find('.fbPagesTipsRating')&.first('div[style*="clip"]')['style'].match(/clip: rect\([\d+]px, (\d+)px/).try(:[], 1)
      rating = container ? container.to_i / 20 : nil
    else
      rating_string = article.first('i u')&.text&.strip
      rating = rating_string.present? ? rating_string.to_i : nil
    end

    read_more_link = article.first('a', text: 'See More', visible: :all)

    if read_more_link
      read_more_link.trigger('click')
      wait 0.1, message: 'Wait See More'
    end

    body = (article.first('strong + span + span + span') || article.first('strong + div + div > span'))&.text
    date = article.first('a abbr')['data-utime']
    original_url = article.first('a[href*="activity"]').try(:[], 'href')

    posted_at = Time.at(date.to_i).to_date rescue Date.today

    attributes = {
        author: author,
        original_rating: rating,
        posted_at: posted_at,
        content: body,
        origin_url: original_url,
        title: body.truncate_words(8, omission: '')
    }

    @articles.push attributes
  end

  def parse_article(article)
    # When user quote other user review, markup of quote looks the same but without link to profile
    return if article.first('.profileLink').blank?

    author = article.first('.profileLink').text.strip
    rating_string = article.first('u').try(:text).try(:strip)
    rating = rating_string.present? ? rating_string.to_i : nil

    read_more_link = article.first('a', text: 'See More', visible: :all)

    if read_more_link
      read_more_link.trigger('click')
      wait 0.1, message: 'Wait See More'
    end

    body = article.first(".userContent").text
    date = article.first("a abbr")['title']
    original_url = article.first('a._5pcq')&.try(:[], 'href')

    posted_at = Date.parse(date) rescue Date.today

    attributes = {
      author: author,
      original_rating: rating,
      posted_at: posted_at,
      content: body,
      origin_url: original_url,
      title: body.truncate_words(8, omission: '')
    }

    @articles.push attributes
  end

  def has_captcha?(doc)
    doc.has_content?(/Security check/i)
  end

  def not_available?(doc)
    doc.has_content?(/isn't available/i)
  end

  def must_login?(doc)
    doc.has_content?(/You must log in to continue/i)
  end

  def change_language_for(doc)
    doc.first('a', text: 'English (US)')&.click || doc.first('a', text: 'English (UK)')&.click
  end
end
