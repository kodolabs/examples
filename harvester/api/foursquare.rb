class Api::Foursquare < Api::Base
  URL = "https://api.foursquare.com/v2/"

  CRAWLING_LIMIT = 500
  API_DATE = '20161608'

  def initialize(options)
    @id = options[:id]
    @driver = options[:driver]
    @lat, @lng = options[:lat], options[:lng]
    @location = options[:location]
    @distance = options[:distance]
  end

  def fetch_articles
    api_url = File.join URL, 'venues', @id, 'tips'

    params = {
      sort: 'recent',
      limit: CRAWLING_LIMIT
    }

    options = { query: base_params.merge(params) }

    log "GET #{api_url}?#{params.to_query}"

    response = HTTParty.get(api_url, options)

    articles_response = response
      .try(:[], 'response')
      .try(:[], 'tips')
      .try(:[], 'items')

    if response.blank? || articles_response.nil?
      log "Response body: #{response.try(:body)}"
      return { status: 'error' }
    end

    result = articles_response.map do |article|

      body = article['text']
      posted_at = Time.at(article['createdAt']).to_date

      user = article['user']
      author = [user['firstName'], user['lastName']].compact.join(" ")

      {
        author: author,
        rating: nil,
        posted_at: posted_at,
        content: body,
        origin_url: nil,
        title: body.truncate_words(8, omission: '')
      }
    end

    { status: 'success', articles: result }
  rescue => e
    log e.message + e.backtrace.join("\n")
    return { status: 'error' }
  end

  def fetch_suggestions
    api_url = URI.join URL, 'venues/search'

    params = { ll: [@lat, @lng].join(','), query: @location, radius: @distance }

    options = {
      query: base_params.merge(params),
    }

    log "GET #{api_url}?#{params.to_query}"
    response = HTTParty.get(api_url, options)

    suggestions_response = response
      .try(:[], 'response')
      .try(:[], 'venues')

    if response.blank? || suggestions_response.blank?
      log "Response body: #{response.try(:body)}"
      return []
    end

    suggestions_response
  rescue => e
    log e.message + e.backtrace.join("\n")
    return []
  end

  private

  def log(message)
    if @driver.try(:history)
      @driver.history += "#{message}\r\n"
    end

    super(message)
  end

  def base_params
    {
      client_id: ENV['FOURSQUARE_CLIENT_ID'],
      client_secret: ENV['FOURSQUARE_CLIENT_SECRET'],
      v: API_DATE,
      m: 'foursquare',
      locale: 'en'
   }
  end
end
