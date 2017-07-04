class Facebook::FetchGenders
  def initialize(api, page, options)
    @api = api
    @page = page
    @options = options
  end

  def call
    @api.get_connection(
      @page.api_handle, 'insights/page_impressions_by_age_gender_unique',
      @options
    )
  end
end
