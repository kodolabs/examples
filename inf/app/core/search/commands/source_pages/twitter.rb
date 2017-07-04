class Search::Commands::SourcePages::Twitter < Search::Commands::SourcePages::Base
  def call
    service = Twitter::Service.new(account)
    client = service.client

    results = client.user_search(@params[:q], include_entities: false)
    format results
  end

  private

  def format(results)
    results.map do |res|
      {
        title: res.name,
        handle: res.screen_name
      }
    end
  end

  def account
    OpenStruct.new(
      token: ENV['TWITTER_USER_KEY'],
      secret: ENV['TWITTER_USER_SECRET']
    )
  end
end
