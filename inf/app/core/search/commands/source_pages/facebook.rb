class Search::Commands::SourcePages::Facebook < Search::Commands::SourcePages::Base
  def call
    client = ::Facebook::Service.new.graph

    results = client.search(@params[:q], type: :page, fields: %w(username name link))
    format results
  end

  private

  def format(results)
    results.select { |res| res['username'].present? }.map do |res|
      {
        title: res['name'],
        handle: res['username']
      }
    end
  end
end
