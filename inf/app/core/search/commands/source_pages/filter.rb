class Search::Commands::SourcePages::Filter
  def initialize(response, options)
    @response = response
    @customer = options[:customer]
    @provider = options[:provider]
  end

  def call
    @response.reject { |res| already_added?(res[:handle]) }
  end

  private

  def already_added?(handle)
    handles.any? { |s| s.casecmp(handle).zero? }
  end

  def handles
    @handles ||= @customer.primary_feed.pages.where(provider: @provider).pluck(:handle)
  end
end
