class Search::Commands::SourcePages::Base
  def initialize(params, customer)
    @params = params
    @provider_id = params[:provider]
    @customer = customer
  end

  def call
    @provider = Provider.find(@provider_id)
    klass = "Search::Commands::SourcePages::#{@provider.name.capitalize}"
    res = klass.constantize.new(@params, @customer).call
    filter(res)
  rescue
    return []
  end

  private

  def filter(res)
    Search::Commands::SourcePages::Filter.new(res, customer: @customer, provider: @provider).call
  end
end
