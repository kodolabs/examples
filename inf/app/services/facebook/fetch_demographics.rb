class Facebook::FetchDemographics
  FIELDS = %w(
    page_fans_country
    page_fans_gender_age
    page_storytellers_by_age_gender
    page_story_adds_by_country_unique
    page_impressions_by_country_unique
    page_impressions_by_age_gender_unique
  ).freeze

  def initialize(api, page, options)
    @api = api
    @page = page
    @options = options
  end

  def call
    @api.get_connection(
      @page.api_handle, "insights/#{FIELDS.join(',')}",
      @options
    )
  end
end
