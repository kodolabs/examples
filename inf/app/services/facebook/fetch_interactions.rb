class Facebook::FetchInteractions
  def initialize(api, page, options)
    @api = api
    @page = page
    @options = options
  end

  def call
    @api.get_connection(
      @page.api_handle, 'insights/page_engaged_users',
      @options
    )
  end
end
