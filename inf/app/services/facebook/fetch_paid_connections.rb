class Facebook::FetchPaidConnections
  def initialize(api, page, options)
    @api = api
    @page = page
    @options = options
  end

  def call
    @api.get_connection(
      @page.api_handle, 'insights/page_impressions_paid',
      @options
    )
  end
end
