class Facebook::Service
  attr_accessor :graph

  def initialize(account = nil)
    token = account.presence ? account.token : app_token
    @graph = Koala::Facebook::API.new(token)
  rescue Koala::Facebook::ServerError
    nil
  end

  def app_token
    oauth = Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
    oauth.get_app_access_token
  end

  def page_present?(handle)
    @graph.get_object(handle)
  rescue
    false
  end

  def fetch_posts(handle, attrs)
    @graph.get_connection(handle, 'posts', attrs)
  rescue
    false
  end

  def fetch_pages
    @graph.get_connection('me', 'accounts', fields:
          %w(id name access_token is_published username picture.type(normal)))
  end

  def debug_token(account_token)
    @graph.debug_token(account_token)
  end

  def fetch_followed_pages(options)
    @graph.get_connection('me', 'likes', limit: options[:limit],
                                         fields: %w(name username picture))
  end
end
